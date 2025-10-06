package serv.util;

import java.io.PrintStream;
import org.apache.log4j.Category;
import org.apache.log4j.Logger;

public class ServLog
{

    static Logger logger;
    long start;
    long stop;
    int limit;
    String sql;
    String sessionId;
    String userId;
    String jName;

    static 
    {
        logger = Logger.getLogger(serv.util.ServLog.class.getName());
    }
/**
 * ServLog constructor comment.
 */
public ServLog() {
	super();
}
    public ServLog(int sessionId, String userId, String jName)
    {
        start = 0L;
        stop = 0L;
        limit = 7;
        sql = "";
        this.sessionId = "";
        this.userId = "";
        this.jName = "";
        this.sessionId = Integer.toString(sessionId);
        this.userId = userId;
        this.jName = jName;
    }
    public ServLog(String userId, String jName)
    {
        start = 0L;
        stop = 0L;
        limit = 7;
        sql = "";
        sessionId = "";
        this.userId = "";
        this.jName = "";
        this.userId = userId;
        this.jName = jName;
    }
    public ServLog(String sessionId, String userId, String jName)
    {
        start = 0L;
        stop = 0L;
        limit = 7;
        sql = "";
        this.sessionId = "";
        this.userId = "";
        this.jName = "";
        this.sessionId = sessionId;
        this.userId = userId;
        this.jName = jName;
    }
    public ServLog(String sessionId, String userId, String jName, int limit)
    {
        start = 0L;
        stop = 0L;
        this.limit = 7;
        sql = "";
        this.sessionId = "";
        this.userId = "";
        this.jName = "";
        this.sessionId = sessionId;
        this.userId = userId;
        this.jName = jName;
        this.limit = limit;
    }
    public long elapsedMillis()
    {
        return stop - start;
    }
    public double elapsedMinutes()
    {
        return (double)(stop - start) / 60000D;
    }
    public double elapsedSeconds()
    {
        return (double)(stop - start) / 1000D;
    }
    public synchronized void endLog()
    {
        try
        {
            String time = "";
            double elapsed = 0.0D;
            endTime();
            elapsed = elapsedSeconds();
            time = Double.toString(elapsed);
            if(elapsed > (double)limit)
            {
                //logger.info(sessionId + "|" + userId + "|" + jName + "|" + time + "|" + sql);
            }
            sql = "";
        }
        catch(Exception e)
        {
            System.out.println("CrmLog : " + e.getMessage());
        }
    }
    public void endTime()
    {
        stop = System.currentTimeMillis();
    }
    public synchronized void errLog(String errMsg)
    {
        logger.error(sessionId + "|" + userId + "|" + jName + "|" + errMsg + "|" + sql);
    }
    public void setLimit(int limit)
    {
        this.limit = limit;
    }
    public void startLog(String sql)
    {
        this.sql = sql;
        start = System.currentTimeMillis();
    }
}
