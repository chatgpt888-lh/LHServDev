package serv.service;

import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.ServletException;

import serv.model.ListServInfBoqBean;

public interface ServService {
	public ListServInfBoqBean listInfBoqByLike(String param_n_itmjob,int max_row, int start_row, int end_row,String listType) throws SQLException,Exception;
	public ListServInfBoqBean listInfBoqByGroup(String i_type, String i_group, int max_row, int start_row, int end_row,String listType) throws SQLException,Exception;
	public int getMaxRow(String i_type, String i_group, String n_itmjob, String searchType)throws SQLException,Exception;
}
