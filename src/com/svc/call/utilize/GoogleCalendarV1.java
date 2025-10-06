package com.svc.call.utilize;
import java.io.IOException;
import com.google.gdata.client.Query;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.DateTime;
import com.google.gdata.data.Feed;
import com.google.gdata.data.PlainTextConstruct;
import com.google.gdata.data.calendar.CalendarEntry;
import com.google.gdata.data.calendar.CalendarEventEntry;
import com.google.gdata.data.calendar.CalendarEventFeed;
import com.google.gdata.data.calendar.CalendarFeed;
import com.google.gdata.data.calendar.ColorProperty;
import com.google.gdata.data.calendar.SelectedProperty;
import com.google.gdata.data.extensions.When;
import com.google.gdata.util.InvalidEntryException;
import com.google.gdata.util.ServiceException;
import com.svc.call.bean.GCalendarBean;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class GoogleCalendarV1 {
	
	//public void doListCalendar(){
	//}
	
	public List doSearchCalendar(CalendarService service,String query,URL feedUrl)throws ServiceException, IOException {
        List eventList  = new ArrayList();
        HashMap hMap = null;
        CalendarEventEntry  eventEntry = null;
       // postURL = new URL("http://www.google.com/calendar/feeds/p093iqnp6676m22cjc2f3v5edg@group.calendar.google.com/private/full");
        //CalendarQuery myQuery = new CalendarQuery(postURL);
        Query myQuery = new Query(feedUrl);
        myQuery.setFullTextQuery(query);

        CalendarEventFeed rsEventFeed = service.query(myQuery, CalendarEventFeed.class);
        
        for (int i = 0; i < rsEventFeed.getEntries().size(); i++) {
        	hMap = new HashMap();
            eventEntry = (CalendarEventEntry)rsEventFeed.getEntries().get(i);
        	
        	hMap.put("title", eventEntry.getTitle().getPlainText());
        	hMap.put("content", eventEntry.getPlainTextContent());
        	hMap.put("gid", eventEntry.getId().toString());
        	hMap.put("refId", eventEntry.getIcalUID().toString());

        	List whenList = eventEntry.getTimes();
        	for(int j = 0 ; j < whenList.size() ; j++ ){
        		When when = (When)whenList.get(j);
        		
        		hMap.put("start_time", when.getStartTime().toUiString());
        		hMap.put("end_time", when.getEndTime().toUiString());
        	}
        	eventList.add(hMap);
        }
        return eventList;
	}
	
	//ADD
	public void  doAddCalendarEventEntry(CalendarService service,CalendarEventEntry entryObj,URL feedUrl)
	throws ServiceException, IOException {
		service.insert(feedUrl, entryObj);
	}

	//Update content or subject
	public void doUpdateCalendarEventEntry(CalendarService service,CalendarEventEntry entryObj)
	throws ServiceException, IOException {
		
	 	URL editUrl = new URL(entryObj.getEditLink().getHref());
	 	service.update(editUrl, entryObj);
	}
	
	//Get Feed
	public static CalendarEventEntry doGetFeedAllEventsById(CalendarService service,URL eventFeedUrl,String uid)
      throws ServiceException, IOException {
	  
	  	CalendarEventEntry entryObj = new CalendarEventEntry();
		// Send the request and receive the response:
		CalendarEventFeed resultFeed = service.getFeed(eventFeedUrl, CalendarEventFeed.class);

	    System.out.println("---Get one events on your calendar equals uuid ---");
	    System.out.println();
	    for (int i = 0; i < resultFeed.getEntries().size(); i++) {
	      CalendarEventEntry entry = resultFeed.getEntries().get(i);
	      //System.out.println("\t" + entry.getTitle().getPlainText());
	      if(uid.equals(entry.getIcalUID().toString())){
	    	  entryObj = resultFeed.getEntries().get(i);
	      }
	    }
	    // System.out.println();
	    return entryObj;
   }
	
	//Delete
	//true = delete success
	//false = delete false
	public static boolean doDeleteFeedAllEventsById(CalendarService gService,URL eventFeedUrl,String uid)
	  	throws ServiceException, IOException {
	  
	    boolean isDelete = false;	    
	    //New Object calendar
	    //CalendarService gService = new CalendarService(Constant.G_SERVICE);
	    //gService.setUserCredentials(calObj.getGUserName(),calObj.getGPassword());	    
	    
		// Send the request and receive the response:
		CalendarEventFeed resultFeed = gService.getFeed(eventFeedUrl,CalendarEventFeed.class);

	    System.out.println("---Delete calendar UUID :"+uid);
	    System.out.println();
	    for (int i = 0; i < resultFeed.getEntries().size(); i++) {
	      CalendarEventEntry entry = resultFeed.getEntries().get(i);
	      //System.out.println("\t" + entry.getTitle().getPlainText());
	      if(uid.equals(entry.getIcalUID().toString())){
	    	  //entryObj = resultFeed.getEntries().get(i);
			  try {
				   entry.delete();
				   isDelete = true;
				   break;
			   } catch (InvalidEntryException e) {
			       System.out.println("\tUnable to delete primary calendar");
			       isDelete = false;
			   }
	      }
	    }
	    return isDelete;
	}
}
