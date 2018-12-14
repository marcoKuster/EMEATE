/*
 * Utility classes to support Release Events
 *
 *    @testcaseID ADM_ReleaseEventTriggerTest
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 *
 */

public with sharing class ADM_ReleaseEvent {
    
    // These correspond to the Event_Status__c picklist values
    public static final String RELEASE_EVENT_PREVIEW = 'Preview';
    public static final String RELEASE_EVENT_PLANNED = 'Planned';
    
    private static List<ADM_Release_Calendar__c> releaseCals;
    
    public static List<ADM_Release_Calendar__c> releaseCalendars { 
        get { 
            if (releaseCals == null) {
                releaseCals = [select Calendar_ID__c from ADM_Release_Calendar__c where Name = 'LocalCalendarId' limit 1];
            }
            return releaseCals;
        }
    }

    public static ADM_Release_Event__c setupReleaseEvent(ADM_Release_Event_Template__c rEventTemplate, ADM_Release__c release) {
        if (release.Release_Date__c == null) {
            return null;
        }       
        ADM_Release_Event__c re = new ADM_Release_Event__c(
            Name = rEventTemplate.Event_Template_Name__c,
            Release__c = release.Id,
            Event_Status__c = RELEASE_EVENT_PREVIEW,
            Event_Contact__c = release.Release_Manager__c,
            Scheduled_Start__c = getStartFromReleaseEventTemplate(rEventTemplate, release),
            Origination__c = rEventTemplate.Id
        );
        re.Scheduled_End__c = re.Scheduled_Start__c.addMinutes((Integer)rEventTemplate.Event_Duration__c);
        re.Deployment_Instances__c = getInstancesFromKey(rEventTemplate.Instance_Key__c, release.Deployment_Instances__c);
        if (rEventTemplate.Notify_Customers__c != null && 
            rEventTemplate.Notify_Customers__c.equalsIgnoreCase(ADM_ReleaseEventTemplate.NOTIFY_CUSTOMERS_YES) &&
            release.Customer_Facing_Release_Name__c != null && release.Customer_Facing_Release_Name__c.length() != 0) {
            re.Customer_Facing_Name__c = release.Customer_Facing_Release_Name__c;
        }
        return re;
    }
    
    public static ADM_Release_Event__c setupReleaseEvent(ADM_Release__c release) {
        if (release.Release_Date__c == null) {
            return null;
        }
        ADM_Release_Event__c re = new ADM_Release_Event__c(
            Name = release.Name,
            Release__c = release.Id,
            Event_Status__c = RELEASE_EVENT_PLANNED,
            Event_Contact__c = release.Release_Manager__c,
            Scheduled_Start__c = release.Release_Date__c,
            Deployment_Instances__c = release.Deployment_Instances__c,
            Origination__c = null
        );
        if (release.Planned_Duration__c != null) {
            re.Scheduled_End__c = re.Scheduled_Start__c.addMinutes((Integer)release.Planned_Duration__c);
        } else {
            re.Scheduled_End__c = release.Release_Date__c;
        }
        if (release.Customer_Facing_Release_Name__c != null && release.Customer_Facing_Release_Name__c.length() != 0) {
            re.Customer_Facing_Name__c = release.Customer_Facing_Release_Name__c;
        }
        return re;
    }
  
    /*
     *  This method updates the fields of a Release Event that are sensitive to certain fields of the Release record
     */
    public static ADM_Release_Event__c updateReleaseEvent(ADM_Release_Event__c re, ADM_Release__c release, ADM_Release__c oldRelease) {

        // If the Release name was used, it will be at the start of the ReleaseEvent.Name
        if (re.Name.startsWith(OldRelease.Name)) {
            re.Name = re.Name.removeStart(OldRelease.Name);
            re.Name = release.Name + ' ' + re.Name;
            re.Name.trim();
        }
        if (re.Scheduled_Start__c == OldRelease.Release_Date__c && re.Scheduled_End__c == oldRelease.Scheduled_End_Date__c) {
            // Event matches old release's scheduled datetime span, so update end time of event
            // We only do the End Time because the release event will be recreated if the start time changed
            if (release.Planned_Duration__c != null) {
                re.Scheduled_End__c = re.Scheduled_Start__c.addMinutes((Integer)release.Planned_Duration__c);
            } else {
                re.Scheduled_End__c = release.Release_Date__c;              
            }
        }
        re.Customer_Facing_Name__c = release.Customer_Facing_Release_Name__c;       
        re.Event_Contact__c = release.Release_Manager__c;
        return re;
    }    

    public static String getInstancesFromKey(String key, String instances) {
        String instanceText = '';
        if (instances == null || instances.length() == 0 || key == null || key.length() == 0) {
            return instanceText;
        }
        Pattern keyPattern;
        try {
            keyPattern = Pattern.compile(key);
        } catch (Exception e) {
            return instanceText;
        }
        if (keyPattern == null)
            return instanceText;
        Matcher m = keyPattern.matcher(instances);
        if (m == null)
            return instanceText;
        while (m.find()) {
            instanceText += m.group() + ' ';
        }
        return instanceText.trim();
    }

    public static Datetime getStartFromReleaseEventTemplate(ADM_Release_Event_Template__c rEventTemplate, ADM_Release__c release) {
        Datetime start = release.Release_Date__c;
        if (rEventTemplate.Day_Offset__c == null)
            rEventTemplate.Day_Offset__c = 0;       
        if (rEventTemplate.Start_Time__c != null && rEventTemplate.Start_Time__c.length() > 0) {
            String offsetDate = start.addDays((Integer)rEventTemplate.Day_Offset__c).date().format();
            start = Datetime.parse(offsetDate + ' ' + rEventTemplate.Start_Time__c);            
        } else {
            if (rEventTemplate.Hour_Offset__c == null)
                rEventTemplate.Hour_Offset__c = 0;
            if (rEventTemplate.Minute_Offset__c == null)
                rEventTemplate.Minute_Offset__c = 0;
            start = 
            start.addDays((Integer)rEventTemplate.Day_Offset__c).addHours((Integer)rEventTemplate.Hour_Offset__c).addMinutes((Integer)rEventTemplate.Minute_Offset__c);
        }
        return start;
    }

    /*
     * Release record updates that require a full delete/refresh cycle for its Release Events are:
     *
     * Refresh changes: 
     *  Release_Type__c -- this determines which Release Event Templates are applied
     *  Deployment_Instances__c -- Release Event Template Instance Keys may generate different events
     *  Application__c -- each application has different Release Event Templates
     *  Release_Date__c -- each Release Event is based on this value, so just regenerate them all
     *  Scheduled_End_Date__c -- The Zero-offset event depends on this   
     *
     */
    public static Boolean isRefreshReleaseUpdate(ADM_Release__c newRelease, ADM_Release__c oldRelease) {
        if (oldRelease.Application__c != newRelease.Application__c || 
            oldRelease.Release_Date__c != newRelease.Release_Date__c ||
            oldRelease.Scheduled_End_Date__c != newRelease.Scheduled_End_Date__c) {
                return true;
        }
        if (oldRelease.Release_Type__c == null && newRelease.Release_Type__c != null ||
            oldRelease.Release_Type__c != null && !oldRelease.Release_Type__c.equalsIgnoreCase(newRelease.Release_Type__c)) {
                return true;
        }
        if (oldRelease.Deployment_Instances__c == null && newRelease.Deployment_Instances__c != null ||
            oldRelease.Deployment_Instances__c != null && !oldRelease.Deployment_Instances__c.equalsIgnoreCase(newRelease.Deployment_Instances__c)) {
                return true;
        }
        return false;
    }

    /*
     * Release record updates that require only an update of Release Events are:
     *
     * Update changes:
     *  Name -- Release Events created when no Release Event Templates are found use the Release.Name for the ReleaseEvent.Name
     *  Customer_Facing_Release_Name__c -- Release Events should be updated with new value
     *  Release_Manager__c -- each Release Event should be updated with the new Event Contact    
     *
     */
    public static Boolean isUpdateReleaseUpdate(ADM_Release__c newRelease, ADM_Release__c oldRelease) {
        
        if (oldRelease.Name == null && newRelease.Name != null ||
            oldRelease.Name != null && !oldRelease.Name.equalsIgnoreCase(newRelease.Name)) {
            return true;
        }
        
        if (oldRelease.Release_Manager__c != newRelease.Release_Manager__c ||
            oldRelease.Customer_Facing_Release_Name__c == null && newRelease.Customer_Facing_Release_Name__c != null ||
            oldRelease.Customer_Facing_Release_Name__c != null && (newRelease.Customer_Facing_Release_Name__c == null ||
                !oldRelease.Customer_Facing_Release_Name__c.equalsIgnoreCase(newRelease.Customer_Facing_Release_Name__c))) {
            return true;
        }
        return false;
    }
    
    /*
     * Base Release Events have start/end times that match the Base Release Date and Base End Date
     *
     */
     
    public static Boolean isBaseReleaseEvent(ADM_Release__c rel, ADM_Release_Event__c re) {
        return (re.Scheduled_Start__c.getTime()/1000 == rel.Release_Date__c.getTime()/1000 && 
                re.Scheduled_End__c.getTime()/1000 == (rel.Scheduled_End_Date__c.getTime()/1000));
    }  

    /*
     * Creates a list of Release Events for this release from an Application's Release Event Templates.
     */

    public static List<ADM_Release_Event__c> releaseEventsFromReleaseEventTemplates(List<ADM_Release_Event_Template__c> rEventTemplates, ADM_Release__c release) {
        
        List<ADM_Release_Event__c> rEvents = new List<ADM_Release_Event__c>();
        if (rEventTemplates != null) {          // No Release Event Templates? Return a zero-offset release event
            for (ADM_Release_Event_Template__c ret : rEventTemplates) {
                
                if (ret.Release_Type__c != null && 
                    ADM_ReleaseEventTemplate.releaseTypeMap.get(release.Release_Type__c) != null &&
                    ret.Release_Type__c.contains(ADM_ReleaseEventTemplate.releaseTypeMap.get(release.Release_Type__c))) {
                    ADM_Release_Event__c re = setupReleaseEvent(ret, release);

                    if (re == null) {
                        continue;
                    }
                    if (re.Scheduled_Start__c == release.Release_Date__c &&     // Zero offset for start time and
                        (re.Scheduled_End__c == re.Scheduled_Start__c ||        // Event Duration WAS SET TO ZERO or
                        re.Scheduled_End__c == release.Scheduled_End_Date__c)) {// End time matches Release's End time
                        re.Event_Status__c = RELEASE_EVENT_PLANNED;             // Zero offset events are always "Planned"
                        re.Scheduled_End__c = release.Scheduled_End_Date__c;    // and have same duration as the Release
                        if (re.Name.contains(ADM_ReleaseEventTemplate.BASE_EVENT_NAME)) {
                            re.Name = release.Name;
                        }
                    }
                    rEvents.add(re);
                }
            }
        }
        // Create a Planned Release Event if either there were no Release Event Templates, or none of the Templates matched
        // this Release Type
        if (rEvents.size() == 0) {          
            ADM_Release_Event__c re = setupReleaseEvent(release);
            if (re != null) {
                rEvents.add(re);
            }
        }

        return rEvents;     
    }

    /*
     * Returns a list of Release Events which were generated from Release Event Templates.
     */

    public static List<ADM_Release_Event__c> eventsGeneratedFromTemplates(List<ADM_Release_Event__c> releaseEvents, 
        List<ADM_Release_Event_Template__c> releaseEventTemplates, ADM_Release__c release) {
        List<ADM_Release_Event__c> reFromTemplates = new List<ADM_Release_Event__c>();
        if (releaseEventTemplates == null) {
            ADM_Release_Event__c reRelease = setupReleaseEvent(release);
            if (reRelease == null) {
                return null;
            }
            for (ADM_Release_Event__c re : releaseEvents) {
                if (re != null && re.Scheduled_Start__c == reRelease.Scheduled_Start__c && 
                    re.Scheduled_End__c == reRelease.Scheduled_End__c && re.Origination__c == null) {
                    reFromTemplates.add(re);
                    break;
                }
            }
        } else {
            Map<Id, ADM_Release_Event__c> reOriginationMap = new Map<Id, ADM_Release_Event__c>();
            for (ADM_Release_Event__c re : releaseEvents) {
                reOriginationMap.put(re.Origination__c, re);
            }
            for (ADM_Release_Event_Template__c ret : releaseEventTemplates) {
                ADM_Release_Event__c re = reOriginationMap.get(ret.Id);
                if (re != null) {
                    reFromTemplates.add(re);
                }
            }
        }
        if (reFromTemplates.size() == 0) {
            reFromTemplates = null;
        }
        return(reFromTemplates);
    }   

    /*
     * Changes to the Release record that require updates to Release Events are:
     *  Customer_Facing_Release_Name__c -- Release Events should be updated with new value
     *  Release_Manager__c -- each Release Event should be updated with the new Event Contact        
     *
     * Note that
     *  Scheduled_End_Date__c -- Only affects Release Events created from the original Release record. That event will be checked/updated.
     */
    public static List<ADM_Release_Event__c> updateReleaseEventsFromRelease(List<ADM_Release_Event__c> releaseEvents, 
        ADM_Release__c release, ADM_Release__c oldRelease) {

        List<ADM_Release_Event__c> updatedReleaseEvents = new List<ADM_Release_Event__c>();    
        for (ADM_Release_Event__c re : releaseEvents) {
            updatedReleaseEvents.add(updateReleaseEvent(re, release, oldRelease));
        }
        return updatedReleaseEvents;
    }
}