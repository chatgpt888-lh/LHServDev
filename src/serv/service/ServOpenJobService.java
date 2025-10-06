package serv.service;

import java.sql.SQLException;
import java.util.ArrayList;

import com.lh.exception.InvalidParameterException;

import serv.model.ServInfOpenJobBean;

public interface ServOpenJobService {
	public ServInfOpenJobBean findOpenJob(String i_docno)throws SQLException,Exception;
	public ArrayList listOpenJob(String itmjob)throws SQLException,Exception;
	public void createOpenJob(ServInfOpenJobBean openJobBean,String save_type)throws SQLException,InvalidParameterException,Exception;
	public void updateOpenJob(ServInfOpenJobBean openJobBean,String save_type)throws SQLException,InvalidParameterException,Exception;
	
}
