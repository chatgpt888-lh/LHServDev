package serv.common;

import java.io.PrintStream;
import java.io.Serializable;

public class User
    implements Serializable
{

    private String UserID;
    private String UserName;
    private String UserWho;
    private String UserACL;
    private String UserGroup;
    private String sessionid;
    private String empId;
    private String empName;
    private String division;
    private String position;
    private String company;
    private String companyId;
    private String divisionId;
    private String email;
    private String group;
    private String venId;
    private String venName;
    private String dbName;
    private int fileNo;
    private String userCom;
    
    
    public String getUserCom() {
		return userCom;
	}

	public void setUserCom(String userCom) {
		this.userCom = userCom;
	}

	public User()
    {
        UserID = "";
        UserName = "";
        UserWho = "";
        UserACL = "";
        UserGroup = "";
        sessionid = "";
        empId = "";
        empName = "";
        division = "";
        position = "";
        company = "";
        companyId = "";
        divisionId = "";
        email = "";
        group = "";
        venId = "";
        venName = "";
        dbName = "";
        UserID = "";
        UserName = "";
        UserWho = "";
        UserACL = "";
        sessionid = "";
        empId = "";
        empName = "";
        division = "";
        position = "";
        email = "";
        venId = "";
        venName = "";
        dbName = "";
        fileNo = 1;
    }

    public String getCompany()
    {
        return company;
    }

    public String getCompanyId()
    {
        return companyId;
    }

    public String getDbName()
    {
        return dbName;
    }

    public String getDivision()
    {
        return division;
    }

    public String getDivisionId()
    {
        return divisionId;
    }

    public String getEmail()
    {
        return email;
    }

    public String getEmpId()
    {
        return empId;
    }

    public String getEmpName()
    {
        return empName;
    }

    public String getGroup()
    {
        return group;
    }

    public String getPosition()
    {
        return position;
    }

    public String getsessionId()
    {
        return sessionid;
    }

    public String getUserACL()
    {
        if(UserACL == null)
        {
            try
            {
                UserACL = new String();
            }
            catch(Throwable exception)
            {
                System.err.println("Exception creating userACL property.");
            }
        }
        return UserACL;
    }

    public String getUserID()
    {
        if(UserID == null)
        {
            try
            {
                UserID = new String();
            }
            catch(Throwable exception)
            {
                System.err.println("Exception creating userID property.");
            }
        }
        return UserID;
    }

    public String getUserName()
    {
        if(UserName == null)
        {
            try
            {
                UserName = new String();
            }
            catch(Throwable exception)
            {
                System.err.println("Exception creating username property.");
            }
        }
        return UserName;
    }

    public String getUserWho()
    {
        if(UserWho == null)
        {
            try
            {
                UserWho = new String();
            }
            catch(Throwable exception)
            {
                System.err.println("Exception creating userwho property.");
            }
        }
        return UserWho;
    }

    public String getVenId()
    {
        return venId;
    }

    public String getVenName()
    {
        return venName;
    }

    public void setCompany(String newCompany)
    {
        company = newCompany;
    }

    public void setCompanyId(String newCompanyId)
    {
        companyId = newCompanyId;
    }

    public void setDbName(String newDbName)
    {
        dbName = newDbName;
    }

    public void setDivision(String newDivision)
    {
        division = newDivision;
    }

    public void setDivisionId(String newDivisionId)
    {
        divisionId = newDivisionId;
    }

    public void setEmail(String newEmail)
    {
        email = newEmail;
    }

    public void setEmpId(String newEmpId)
    {
        empId = newEmpId;
    }

    public void setEmpName(String newEmpName)
    {
        empName = newEmpName;
    }

    public void setGroup(String newGroup)
    {
        group = newGroup;
    }

    public void setPosition(String newPosition)
    {
        position = newPosition;
    }

    public void setsessionId(String id)
    {
        sessionid = id;
    }

    public void setUserACL(String userACL)
    {
        UserACL = userACL;
    }

    public void setUserID(String userid)
    {
        UserID = userid;
    }

    public void setUserName(String userName)
    {
        UserName = userName;
    }

    public void setUserWho(String userWho)
    {
        UserWho = userWho;
    }

    public void setVenId(String newVenId)
    {
        venId = newVenId;
    }

    public void setVenName(String newVenName)
    {
        venName = newVenName;
    }

    public int getFileNo()
    {
        int no = fileNo;
        fileNo++;
        return no;
    }

    public void setFileNo(int fileNo)
    {
        this.fileNo = fileNo;
    }

	public String getUserGroup() {
		return UserGroup;
	}

	public void setUserGroup(String userGroup) {
		UserGroup = userGroup;
	}
}