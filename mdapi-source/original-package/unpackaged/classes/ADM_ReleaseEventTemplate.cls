/*
 * Utility classes to support Release Event Templates
 *
 *    @testcaseID ADM_ReleaseTriggerTest
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 *
 */

public with sharing class ADM_ReleaseEventTemplate {
    
    // These correspond to the Release_Type__C picklist values
    public static final String RELEASE_TYPE_MAJOR = ADM_Release.RELEASE_TYPE_MAJOR;
    public static final String RELEASE_TYPE_PATCH = ADM_Release.RELEASE_TYPE_PATCH;
    public static final String RELEASE_TYPE_ERELEASE = 'eRelease';
    public static final String RELEASE_TYPE_OTHER = ADM_Release.RELEASE_TYPE_OTHER; 
    public static final String RELEASE_TYPE_PATERR = RELEASE_TYPE_PATCH + ';' + RELEASE_TYPE_ERELEASE;
    public static final String RELEASE_TYPE_ALL = RELEASE_TYPE_MAJOR + ';' + RELEASE_TYPE_PATCH + ';' + RELEASE_TYPE_ERELEASE + ';' + RELEASE_TYPE_OTHER;
    public static final String BASE_EVENT_NAME = 'Base Event';

    public static final Map<String, String> releaseTypeMap = new Map<String, String>{
        ADM_Release.RELEASE_TYPE_MAJOR => RELEASE_TYPE_MAJOR,
        ADM_Release.RELEASE_TYPE_PATCH => RELEASE_TYPE_PATCH,
        ADM_Release.RELEASE_TYPE_ERELEASE => RELEASE_TYPE_ERELEASE,
        ADM_Release.RELEASE_TYPE_OTHER => RELEASE_TYPE_OTHER
    };
    
    // These correspond to the Notify_Customers__c picklist
    public static final String NOTIFY_CUSTOMERS_YES = 'Yes';
    public static final String NOTIFY_CUSTOMERS_NO = 'No';

    public static ADM_Release_Event_Template__c setupReleaseEventTemplate(ADM_Application__c app,
            String eventTemplateName, Integer eventDuration, String notifyCustomers, String releaseType,
            Integer dayOffset,  Integer hourOffset, Integer minuteOffset, String startTime, 
            String instanceKey) {
        if (app == null || dayOffset == null || releaseType == null) {
            return null;
        }
        ADM_Release_Event_Template__c ret = new ADM_Release_Event_Template__c(
            Event_Template_Name__c = eventTemplateName,
            Event_Duration__c = eventDuration,
            Notify_Customers__c = notifyCustomers,
            Release_Type__c = releaseType,
            Instance_Key__c = instanceKey,
            Day_Offset__c = dayOffset,
            Application__c = app.Id);

        if (startTime != null && startTime.length() > 0) {
            ret.Start_Time__c = startTime;
        } else {
            ret.Hour_Offset__c = hourOffset;
            ret.Minute_Offset__c = minuteOffset;            
        }

        return ret;
    }
  
    /*
     * Create a set of Release Event Templates to use for tests
     *
     * Test code is expected to fill in or update offsets, start time and other fields as needed before insert
     */

    public static List<ADM_Release_Event_Template__c> setupTestReleaseEventTemplates(ADM_Application__c app, String releaseType, Integer count) {
            
        final Integer TEST_DURATION = 30;
        List<ADM_Release_Event_Template__c> retList = new List<ADM_Release_Event_Template__c>();
        for (Integer i=0; i < count; i++) {
            ADM_Release_Event_Template__c ret = setupReleaseEventTemplate(app,
                'Test Template ' + i,
                TEST_DURATION,
                /*notifyCustomers*/ null,                   
                releaseType,
                /*dayOffset*/  i,      // count used for test dayOffset value
                /*hourOffset*/  null,  
                /*minuteOffset*/  null,  
                /*startTime*/  null,  
                /*instanceKey*/  null
                );
            retList.add(ret);
        }   
        return retList;
    }
 
    /*
     * Creates a Base Release Event Template for all Release Types when an Application record is first created.
     */

     public static ADM_Release_Event_Template__c setupBaseReleaseEventTemplate(ADM_Application__c app) {
        
        ADM_Release_Event_Template__c ret = setupReleaseEventTemplate(app,
                app.Name + ' ' +  BASE_EVENT_NAME,
                /*eventDuration*/  0,
                /*notifyCustomers*/ NOTIFY_CUSTOMERS_NO,                    
                /*releaseType*/  RELEASE_TYPE_ALL,
                /*dayOffset*/  0,      // count used for test dayOffset value
                /*hourOffset*/  0,  
                /*minuteOffset*/  0,  
                /*startTime*/  null,  
                /*instanceKey*/  null
                );
        return ret;             
     }
     
     public static Boolean isBaseEventTemplate(ADM_Release_Event_Template__c ret) {
        return (ret.Day_Offset__c == 0 && ret.Event_Duration__c == 0 && ret.Hour_Offset__c == 0 && ret.Minute_Offset__c == 0);
     }  
}