public class ADM_Release {
	
	// These correspond to the Release_Type__C picklast values
	public static final String RELEASE_TYPE_MAJOR = 'Major';
	public static final String RELEASE_TYPE_PATCH = 'Patch';
	public static final String RELEASE_TYPE_ERELEASE = 'e';
	public static final String RELEASE_TYPE_OTHER = 'Other';
	

	public static final String TEST_RELEASE_NAME = 'Test Release Name';
	public static final Integer RELEASE_DEFAULT_DURATION = 60;
	
	private static final String FIELD_NAMES = 'Id, Name, Release_Date__c, Release_Type__c, Short_Note__c, Status__c';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Release__c a';
	
    public static ADM_Release__c[] getAllBy( String columnName, Set<String> columnValues) {
        ADM_Release__c[] works = null;
        try{
        	String inColumnValues = COM_SoqlUtils.createInClause(columnName, new List<String>(columnValues));
        	String sql = SQL_SELECT + SQL_FROM + ' where ' + inColumnValues;
        	
            works = Database.query(sql);
        } catch( System.Exception e ){
            works = new ADM_Release__c[0];
        }
        
        return works;
    } 
    
    public static ADM_Release__c getByReleaseName(String releaseName, Id excludedID) {
    	return [select id, Name from ADM_Release__c where id != :excludedID and Name = :releaseName];	
    }	

	public static ADM_Release__c setupTestRelease(String relName, Datetime relDate, Datetime relEndDate, Integer relDuration) {
		ADM_Release__c rel = new ADM_Release__c();
		rel.Name = relName;
		rel.Release_Date__c = relDate;
		rel.Scheduled_End_Date__c = relEndDate;
		rel.Planned_Duration__c = relDuration;
		rel.Release_Type__c = RELEASE_TYPE_PATCH;
		return rel;
	}		
	public static ADM_Release__c createTestRelease() {
		ADM_Release__c rel = setupTestRelease(TEST_RELEASE_NAME, Datetime.now(), null, RELEASE_DEFAULT_DURATION);
		Database.insert(rel);
		return rel;
	}

	public static ADM_Release__c createTestRelease(String relName, Datetime relDate, Datetime relEndDate) {
		ADM_Release__c rel = setupTestRelease(relName, relDate, relEndDate, null);
		if(relEndDate == null) {
			rel.Planned_Duration__c = RELEASE_DEFAULT_DURATION;
		}
		Database.insert(rel);
		return rel;
	}
	public static ADM_Release__c createTestRelease(String relName, Datetime relDate, Datetime relEndDate, Integer relDuration) {
		ADM_Release__c rel = setupTestRelease(relName, relDate, relEndDate, relDuration);
		Database.insert(rel);
		return rel;
	}
	public static ADM_Release__c createTestRelease(String relName, ADM_Application__c relApplication) {
		ADM_Release__c rel = setupTestRelease(relName, Datetime.now(), null, RELEASE_DEFAULT_DURATION);
		rel.Application__c = relApplication.id;
		Database.insert(rel);
		return rel;
	}	
	public static ADM_Release__c createTestRelease(String relName, String relType, ADM_Application__c relApplication, Datetime relDate, Datetime relEndDate) {
	    ADM_Release__c rel = ADM_Release.setupTestRelease(relName, relDate, relEndDate, null);
	    rel.Release_Type__c = relType;
		rel.Application__c = relApplication.id;
		Database.insert(rel);
		return rel;
	}
	
	public static ADM_Released_In__c createTestReleasedIn(ADM_Release__c release) {
		ADM_Released_In__c stamp = new ADM_Released_In__c();
		ADM_Work__c work = ADM_Work.createTestWork();
		stamp.Work__c = work.id;
		stamp.Release__c = release.id;
		stamp.External_ID__c = work.id + '-' + release.id;
		Database.insert(stamp);
		return stamp;
			
	}

	
	/*
	 * These helper functions are called by the trigger and setEndDateWithPrior(), below.
	 * @author snahm
	 */
	static final Integer MILLISECONDS_MINUTE = (1000*60);
	static final Integer MAXEVENTDURATION = /* 14 Days */ 14 * 24 * 60;	// This is a contraint of the Event object
	
	public static Datetime setEndDateByDuration(Datetime releaseDate, Integer duration) {
		if (duration == null || duration < 0) {
			duration = RELEASE_DEFAULT_DURATION;
		}
		if (duration > MAXEVENTDURATION) {
			duration = MAXEVENTDURATION;	// Validation rule should catch most cases, otherwise silently truncate
		}
		return releaseDate.addMinutes(duration);
	}
	public static Integer setDurationByEndDate(Datetime releaseDate, Datetime endDate) {
		if (releaseDate == null)
			return null;
		if (endDate == null) {	// Should not happen
			return RELEASE_DEFAULT_DURATION;
		}
		Integer duration = (Integer) (endDate.getTime() - releaseDate.getTime()) / MILLISECONDS_MINUTE;
		if (duration > MAXEVENTDURATION) {
			duration = MAXEVENTDURATION;
			endDate=setEndDateByDuration(releaseDate, duration);
		}
		return duration;
	}

	/*
	 *	Called from the trigger to set the release End Date based on information in the release record and the
	 * 	prior version of the release record.
	 * 	
	 *	@author snahm
	 */
	public static Datetime setEndDateWithPrior(ADM_Release__c current, ADM_Release__c prior) {
		Datetime currentReleaseDate;
		Datetime currentEndDate;
		Integer currentDuration;
		Datetime priorReleaseDate;
		Datetime priorEndDate;
		Integer priorDuration;		
		
		currentReleaseDate = current.Release_Date__c;
		currentEndDate = current.Scheduled_End_Date__c;
		currentDuration = (Integer)current.Planned_Duration__c;
    	if (prior != null) {	// It's an Update
				priorReleaseDate = prior.Release_Date__c;
				priorEndDate = prior.Scheduled_End_Date__c;
				priorDuration = (Integer)prior.Planned_Duration__c;    			
        	if (currentReleaseDate != priorReleaseDate) { 		
            	if (priorEndDate != null) {
            		if (currentEndDate == null || (currentEndDate == priorEndDate && currentDuration != priorDuration)) {
            			// End Date is null or unchanged, but Release Date and Duration changed, so calulate End Date based on these
            			currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
            		} else if (currentDuration == priorDuration) {
            			// Release Date changed but End Date and Duration was not changed, calculate new End Date based on prior duration
                    currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, priorDuration);
            		}
                } else {
                	if (currentEndDate != null) {
                		currentDuration = ADM_Release.setDurationByEndDate(currentReleaseDate, currentEndDate);
                	}
                	currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
                }
            } else  // Start date did not change
            if (currentEndDate == priorEndDate && currentDuration != priorDuration) {
            	// Release Date and End Date are the same, but Duration changed, calculate new End Date
            	if (currentDuration != null) {            		
            	currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
            }
            }
        } else {	// No prior record so must be an Insert
			if (currentEndDate == null) {
				if (currentDuration != null) {
					currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
				}                      	
       		} else {
       			if (currentEndDate.getTime() < currentReleaseDate.getTime()) {
       				currentEndDate = null;		// This will be cleaned up below
       			} else {
				currentDuration = ADM_Release.setDurationByEndDate(currentReleaseDate, currentEndDate);
				currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);                        	
       		}
    	}
    	}
        if (currentEndDate == null) {
       		if (currentDuration != null) {
                currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
       		}
        } else if (currentEndDate.getTime() < currentReleaseDate.getTime()) {            		
                // Cannot end before we start
            currentEndDate = ADM_Release.setEndDateByDuration(currentReleaseDate, currentDuration);
        }
        return(currentEndDate);
    }

   	/*
   	 * Helper method: getEventsForRelease gets GUS Calendar Events for this release
   	 */
   	public static List<Event> getEventsForRelease(ADM_Release__c release) {
   		List<ADM_Release_Calendar__c> calendars = [select Calendar_ID__c from ADM_Release_Calendar__c where Name = 'LocalCalendarId' limit 1];
   		if (!calendars.isEmpty()) {
			String releaseCalendarId = calendars.get(0).Calendar_ID__c;
	   		Map</*ADM_Release_Event__c*/ Id, ADM_Release_Event__c> releaseEventIds = 
	   			new Map<Id, ADM_Release_Event__c>([select Id from ADM_Release_Event__c where Release__c = :release.id]);
			return [Select id, WhatId, subject, startDateTime, endDateTime, Location, Description from Event where OwnerId  = :releaseCalendarId and WhatId = :releaseEventIds.keySet()];
   		} else {
   			return null;
   		}
   	}
    
    /*
	 * Helper functions for Release Events.
	 *
	 *    @testcaseID ADM_ReleaseTriggerTest
	 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
	 *    @author: snahm
	 *
	 */

    public static Event eventFromReleaseEvent(ADM_Release_Event__c releaseEvent, String releaseCalendarId) {
    	Event event = new Event();
		event = eventFromReleaseEvent(event, releaseEvent, releaseCalendarId);
    	return(event);
    }
    
    public static Event eventFromReleaseEvent(Event event, ADM_Release_Event__c releaseEvent, String releaseCalendarId) {
        event.Subject = releaseEvent.Release_Name__c;
    	event.OwnerId = releaseCalendarId;
        event.WhatId = releaseEvent.Id;
    	event.StartDateTime = releaseEvent.Scheduled_Start__c;
    	event.EndDateTime = releaseEvent.Scheduled_End__c;
    	event.Location = releaseEvent.Application_Name__c;
    	event.Description = releaseEvent.Release_Name__c;
    	if (releaseEvent.Deployment_Instances__c != null && releaseEvent.Deployment_Instances__c.length() > 0) {
    		event.Description += ' to ' + releaseEvent.Deployment_Instances__c;
        }
    	if (releaseEvent.Customer_Facing_Name__c != null && releaseEvent.Customer_Facing_Name__c.length() > 0) {
    		event.Description = event.Description + '\n' + releaseEvent.Customer_Facing_Name__c;		
            }
    	return(event);
    }
}