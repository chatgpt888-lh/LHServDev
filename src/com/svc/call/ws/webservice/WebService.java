package com.svc.call.ws.webservice;
import javax.xml.namespace.QName;
import javax.xml.rpc.ParameterMode;

import org.apache.axis.client.Call;
import org.apache.axis.client.Service;

import com.svc.ws.model.GCalendarRQ;
import com.svc.ws.model.GCalendarRS;
/*
 * date:2014-02-07
 * author: pradoem wongkraso
 * verion 1.0
 * contact : pradoem@lh.co.th,go2doem@gmail.com
 * description: For Communication parameter webService 
 * */
public class WebService {
	
	public static GCalendarRS createCalendar(GCalendarRQ req){
		GCalendarRS objResult = new GCalendarRS();
		try{	
			//System.out.println("Debug -> String createCalendar. ");
		    //System.out.println("Debug -> WebService URL : "+Constant.URL_ADDRESS);
		  
		    Service service = new Service();
			Call call = (Call)service.createCall();
			call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));			
			
			//qname="ns2:getPersonObj"
			//name="getFindPersonObj" qname="operNS:getFindPersonObj"
			//get parameter from wsdl
			QName qin = new QName("GOnlineInterface", "GCalendarRQ");
		    call.registerTypeMapping(GCalendarRQ.class, qin,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRQ.class, qin),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRQ.class, qin));
		      
		     QName qout = new QName("GOnlineInterface", "GCalendarRS");
		     call.registerTypeMapping(GCalendarRS.class, qout,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRS.class, qout),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRS.class, qout));
		      
		     //System.out.println("Debug -> call :"+Constant.OperationName_CreateEvent);
		     call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));
		     call.setOperationName(new QName(Constant.OperationName_CreateEvent,Constant.OperationName_CreateEvent));
		      
		     //System.out.println("Debug ---->> 33333333 ");
		     call.addParameter("arg1", qin, ParameterMode.IN);
		    // System.out.println("Debug -> add Object parameter ");
		     call.setReturnType(qout);
		      
		      //System.out.println("Debug ->SetReturnType. ");
		     objResult = (GCalendarRS) call.invoke(new Object[] {req});  //personRQ
		      
		     //System.out.println("Debug ->Completed. ");
    		//result = res.toStringx();
		}catch(Exception e){
			System.out.println("Debug Exception e!!!:"+e.toString());
			objResult.setError(true);
			objResult.setErrMsg(e.toString());
		}		
		return objResult;
	}
	
	public static GCalendarRS dropCalendar(GCalendarRQ req){
		GCalendarRS objResult = new GCalendarRS();
		try{			
			//System.out.println("Debug -> String dropCalendar. ");
		    //System.out.println("Debug -> WebService URL : "+Constant.URL_ADDRESS);

		    Service service = new Service();
			Call call = (Call)service.createCall();
			call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));			
			//qname="ns2:getPersonObj"
			//name="getFindPersonObj" qname="operNS:getFindPersonObj"
			//get parameter from wsdl
			QName qin = new QName("GOnlineInterface", "GCalendarRQ");
		    call.registerTypeMapping(GCalendarRQ.class, qin,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRQ.class, qin),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRQ.class, qin));
		      
		     QName qout = new QName("GOnlineInterface", "GCalendarRS");
		     call.registerTypeMapping(GCalendarRS.class, qout,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRS.class, qout),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRS.class, qout));
		      
		    // System.out.println("Debug -> call :"+Constant.OperationName_DeleteEventId);
		     call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));
		     call.setOperationName(new QName(Constant.OperationName_DeleteEventId,Constant.OperationName_DeleteEventId));

		     call.addParameter("arg1", qin, ParameterMode.IN);
		    // System.out.println("Debug -> add Object parameter ");
		     call.setReturnType(qout);
		      
		    // System.out.println("Debug ->SetReturnType. ");
		     objResult = (GCalendarRS) call.invoke(new Object[] {req});  //personRQ
		      
		    // System.out.println("Debug ->Completed. ");
    		//result = res.toStringx();
		}catch(Exception e){
			System.out.println("Debug Exception e!!!:"+e.toString());
			objResult.setError(true);
			objResult.setErrMsg(e.toString());
		}		
		return objResult;
	}
	
	
	public static GCalendarRS changeCalendar(GCalendarRQ req){
		GCalendarRS objResult = new GCalendarRS();
		try{			
			//http://localhost:8080/GCALWebService/services/GOnlineInterface?wsdl
			//String url = Constant.URL_ADDRESS;   
		    //System.out.println("WebService URL : "+Constant.URL_ADDRESS);
		    
		    Service service = new Service();
			Call call = (Call)service.createCall();
			call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));			
			//qname="ns2:getPersonObj"
			//name="getFindPersonObj" qname="operNS:getFindPersonObj"
			//get parameter from wsdl
			QName qin = new QName("GOnlineInterface", "GCalendarRQ");
		    call.registerTypeMapping(GCalendarRQ.class, qin,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRQ.class, qin),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRQ.class, qin));
		      
		     QName qout = new QName("GOnlineInterface", "GCalendarRS");
		     call.registerTypeMapping(GCalendarRS.class, qout,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRS.class, qout),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRS.class, qout));
		      
		    // System.out.println("Debug -> call :"+Constant.OperationName_UpdateEvent);
		     call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));
		     call.setOperationName(new QName(Constant.OperationName_UpdateEvent,Constant.OperationName_UpdateEvent));
		      
		     //System.out.println("Debug ---->> 33333333 ");
		     call.addParameter("arg1", qin, ParameterMode.IN);
		     //System.out.println("Debug ---->> 44444444 ");
		     call.setReturnType(qout);
		      
		     //System.out.println("Debug ---->> before call CreateEvent ");
		     objResult = (GCalendarRS) call.invoke(new Object[] {req});  //personRQ
		      
		    // System.out.println("Debug --->> Completed.. ");
    		//result = res.toStringx();
		}catch(Exception e){
			System.out.println("<<---Exception e!!!:"+e.toString());
			objResult.setError(true);
			objResult.setErrMsg(e.toString());
		}		
		return objResult;
	}
	
	public static GCalendarRS searchCalendar(GCalendarRQ req){
		GCalendarRS objResult = new GCalendarRS();
		try{			
			//http://localhost:8080/GCALWebService/services/GOnlineInterface?wsdl
			//String url = Constant.URL_ADDRESS;   
		    //System.out.println("WebService URL : "+Constant.URL_ADDRESS);
		    
		    Service service = new Service();
			Call call = (Call)service.createCall();
			call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));			
			//qname="ns2:getPersonObj"
			//name="getFindPersonObj" qname="operNS:getFindPersonObj"
			//get parameter from wsdl
			QName qin = new QName("GOnlineInterface", "GCalendarRQ");
		    call.registerTypeMapping(GCalendarRQ.class, qin,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRQ.class, qin),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRQ.class, qin));
		      
		     QName qout = new QName("GOnlineInterface", "GCalendarRS");
		     call.registerTypeMapping(GCalendarRS.class, qout,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRS.class, qout),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRS.class, qout));
		      
		     //System.out.println("Debug -> call :"+Constant.OperationName_SearchEventId);
		     call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));
		     call.setOperationName(new QName(Constant.OperationName_SearchEventId,Constant.OperationName_SearchEventId));
		      
		     //System.out.println("Debug -> add Object parameter ");
		     call.addParameter("arg1", qin, ParameterMode.IN);

		     call.setReturnType(qout);
		      
		     //System.out.println("Debug ->SetReturnType. ");
		     objResult = (GCalendarRS) call.invoke(new Object[] {req});  //personRQ
		      
		     //System.out.println("Debug ->Completed. ");
    		//result = res.toStringx();
		}catch(Exception e){
			System.out.println("Exception e!!!:"+e.toString());
			objResult.setError(true);
			objResult.setErrMsg(e.toString());
		}		
		return objResult;
	}
	
	//Method Sync Backup data 2015.08.11
	public static GCalendarRS syncBackupCalendar(GCalendarRQ req){
		GCalendarRS objResult = new GCalendarRS();
		try{			 
		    //System.out.println("WebService URL : "+Constant.URL_ADDRESS);
		    
		    Service service = new Service();
			Call call = (Call)service.createCall();
			call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));			
			QName qin = new QName("GOnlineInterface", "GCalendarRQ");
		    call.registerTypeMapping(GCalendarRQ.class, qin,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRQ.class, qin),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRQ.class, qin));
		      
		     QName qout = new QName("GOnlineInterface", "GCalendarRS");
		     call.registerTypeMapping(GCalendarRS.class, qout,
		                               new org.apache.axis.encoding.ser.
		                               BeanSerializerFactory(GCalendarRS.class, qout),
		                               new org.apache.axis.encoding.ser.
		                               BeanDeserializerFactory(GCalendarRS.class, qout));
		      
		     //System.out.println("Debug -> call :"+Constant.OperationName_SyncBackupCalendar);
		     call.setTargetEndpointAddress(new java.net.URL(Constant.URL_ADDRESS));
		     call.setOperationName(new QName(Constant.OperationName_SyncBackupCalendar,Constant.OperationName_SyncBackupCalendar));
		      
		     //System.out.println("Debug -> add Object parameter ");
		     call.addParameter("arg1", qin, ParameterMode.IN);

		     call.setReturnType(qout);
		      
		     //System.out.println("Debug ->SetReturnType. ");
		     objResult = (GCalendarRS) call.invoke(new Object[] {req});  //personRQ
		      
		     //System.out.println("Debug ->Completed. ");
    		//result = res.toStringx();
		}catch(Exception e){
			System.out.println("Exception e!!!:"+e.toString());
			objResult.setErrMsg(e.toString());
		}		
		return objResult;
	}

}

