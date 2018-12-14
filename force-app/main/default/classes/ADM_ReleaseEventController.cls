/*
 * Controller extention for Release record to support Release Events
 *
 *    @testcaseID ADM_ReleaseEventControllerTest
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 *
 */

public with sharing class ADM_ReleaseEventController {

	private static String releaseEventKeyPrefix = null;
    public List<ADM_Release_Event__c> appReleaseEvent { get ; private set; }	// List of Release Event records for this release
    public Integer appReleaseEventSize { get {return appReleaseEvent.size();} }
    
    private ADM_Release__c release;

    public ADM_ReleaseEventController(ApexPages.StandardController stdController) {
    	this.release = (ADM_Release__c) stdController.getRecord();
    	refreshEventRecords();
    }
 	
    private void refreshEventRecords() {
        Map<Id, ADM_Release_Event__c> appReleaseEventMap;	

    	try {
    		appReleaseEventMap = new Map<Id, ADM_Release_Event__c>([select 
                Name, Application_Name__c, Event_Status__c, Customer_Facing_Name__c, Deployment_Instances__c, Event_Contact__c, 
                	Release__c, Release_Name__c, Scheduled_Start__c, Scheduled_End__c FROM ADM_Release_Event__c 
                   WHERE Release__c =:release.Id ORDER BY Scheduled_Start__c]);
    	} catch (Exception e) {
    		appReleaseEventMap = new Map<Id, ADM_Release_Event__c>();
    	} 
    	appReleaseEvent = appReleaseEventMap.values();
     }
    
    /*
     *	Updates all "Preview" Release Events to "Planned". 
     *  Intended for use by GUS Release Manager profile only.
     */
    public PageReference planReleaseEvents() {   
     
        PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ADM_ReleaseRelatedList?id=' + release.Id);

        List <ADM_Release_Event__c> updateEvent = new List <ADM_Release_Event__c>();

        for (ADM_Release_Event__c releaseEvent : appReleaseEvent) {
			if (releaseEvent.Event_Status__c != null && releaseEvent.Event_Status__c.equalsIgnoreCase(ADM_ReleaseEvent.RELEASE_EVENT_PREVIEW)) {
				releaseEvent.Event_Status__c = ADM_ReleaseEvent.RELEASE_EVENT_PLANNED;
			}
			updateEvent.add(releaseEvent);
        }
        if (updateEvent.size() > 0){
            try {
                Database.update(updateEvent);                  
            } catch (Exception e) {
                System.debug('Exception' +  e);
                pageRef = null;
                return pageRef;
            }
    		refreshEventRecords();
        }
        
        return pageRef;
    }
}