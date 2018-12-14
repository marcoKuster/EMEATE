/**
 *    @userstory W-1268579: Track application information and lifecycle with Application object
 *    @author snahm
 */

public with sharing class ADM_Application {
	
	private static final String CORE_APPLICATION_NAME = 'Core Salesforce Application';
	public static final String CORE_APPLICATION_TYPE = 'Core Salesforce Application';
	private static final String DEFAULT_APPLICATION_NAME = 'TEST APPLICATION NAME';
	private static final String DEFAULT_APPLICATION_TYPE = 'TEST APPLICATION TYPE';
	
	public static String coreApplicationName {
		get {
			if (coreApplicationName == null) {
				coreApplicationName = CORE_APPLICATION_NAME + ' ' + ((Integer)(1000.0 * Math.random()));
			}
			return coreApplicationName;
		}
		private set;
	}
	
	public static String testApplicationName {
		get {
			if (testApplicationName == null) {
				testApplicationName = DEFAULT_APPLICATION_NAME + ' ' + ((Integer)(1000.0 * Math.random()));
			}
			return testApplicationName;
		}
		private set;
	}

	// Matches values of picklist ADM_Application.Category__c
	public static final String CATEGORY_ACTIVE = 'Active';
	public static final String CATEGORY_RETIRED = 'Retired';
	public static final String CATEGORY_PREPRODUCTION = 'Preproduction';
	public static final String CATEGORY_SCHEDULE = 'Schedule';
	
	@IsTest
	public static ADM_Application__c createTestCoreApplication() {
		ADM_Application__c app = new ADM_Application__c(
            Name = coreApplicationName,
            Application_Type__c = CORE_APPLICATION_TYPE,
            Category__c = CATEGORY_ACTIVE,
            Enable_ERR_Notification_Emails__c=false);
        Database.insert(app);
		return app;
	}
	
	@IsTest
	public static ADM_Application__c createTestApplication() {
		ADM_Application__c app = new ADM_Application__c(
            Name = testApplicationName,
            Application_Type__c = DEFAULT_APPLICATION_TYPE,
            Category__c = CATEGORY_ACTIVE,            
            Enable_ERR_Notification_Emails__c=false,
            Enable_Release_Planning__c = false);
        Database.insert(app);
		return app;
	}

    public static Id getCoreAppIdWithAppPlannedDuration(boolean enableReleasePlanning){
        ADM_Application__c app = new ADM_Application__c(
        	Enable_Release_Planning__c = enableReleasePlanning,
            Enable_Release_Planning_Case_Creation__c = enableReleasePlanning,
        	Name = coreApplicationName,
        	Application_Planned_Duration__c = 150, 
        	Application_Type__c = CORE_APPLICATION_TYPE, 
        	Category__c = CATEGORY_ACTIVE);
        insert app;
        return app.Id;
    }	

    public static Id getCoreAppIdWithAppPlannedDuration(boolean enableReleasePlanning, boolean enableCaseGeneration){
        ADM_Application__c app = new ADM_Application__c(
        	Enable_Release_Planning__c = enableReleasePlanning,
            Enable_Release_Planning_Case_Creation__c = enableCaseGeneration,
        	Name = coreApplicationName,
        	Application_Planned_Duration__c = 150, 
        	Application_Type__c = CORE_APPLICATION_TYPE, 
        	Category__c = CATEGORY_ACTIVE);
        insert app;
        return app.Id;
    }	
	
	public static ADM_Application__c createTestApplication(String appName, String appType) {
		ADM_Application__c app = new ADM_Application__c(
            Name = appName,
            Application_Type__c = appType,
            Category__c = CATEGORY_ACTIVE,            
            Enable_ERR_Notification_Emails__c=false,
            Enable_Release_Planning__c = false);
        Database.insert(app);            
		return app;
	}
	
	public static ADM_Application__c createTestApplication(String appName, String appType, Boolean enableEmail) {
		ADM_Application__c app = new ADM_Application__c(
            Name = appName,
            Application_Type__c = appType,
            Category__c = CATEGORY_ACTIVE,            
            Enable_ERR_Notification_Emails__c=enableEmail);
        Database.insert(app);            
		return app;
	}	
	
	public static ADM_Application__c createTestApplication(String appName, String appType, User appPrimaryRM, User appSecondaryRM) {
		Id primary;
		Id secondary;
		if (appPrimaryRM == null) {
			primary = null;
		} else {
			primary = appPrimaryRM.Id;
		}
		if (appSecondaryRM == null) {
			secondary = null;
		} else {
			secondary = appSecondaryRM.Id;
		}
		ADM_Application__c app = new ADM_Application__c(
            Name = appName,
            Application_Type__c = appType,
            Primary_Release_Manager__c = primary,
            Secondary_Release_Manager__c = secondary,
            Category__c = CATEGORY_ACTIVE,            
            Enable_ERR_Notification_Emails__c=false);
        Database.insert(app);            
		return app;
	}

}