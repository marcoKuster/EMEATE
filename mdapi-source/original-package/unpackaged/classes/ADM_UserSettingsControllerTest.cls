/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest

/*
@testcaseID a1DB00000002tyX
@userstory a07B0000000Waqq
@Expected Results The user is able to save GUS settings
@hierarchy GUS.GUS Settings.Work Notification Level
*/
public with sharing class ADM_UserSettingsControllerTest {
	static testMethod void testSaveMethod() {
		User user = ADM_WorkUser.createTestUser();
		
		Schema.DescribeFieldResult notificationFieldDesc = Schema.sObjectType.User.fields.Notification_Level__c;
		List<Schema.PicklistEntry> notificationValues = notificationFieldDesc.getPicklistValues();
		
		Schema.DescribeFieldResult workInterfaceFieldDesc = Schema.sObjectType.User.fields.Work_User_Interface__c;
		List<Schema.PicklistEntry> workInterfaceValues = workInterfaceFieldDesc.getPicklistValues();
		
		String expectedWorkInterface = workInterfaceValues[0].getValue();
		String expectedNotificationLevel = notificationValues[0].getValue();
		user.Work_User_Interface__c = expectedWorkInterface;
		user.Notification_Level__c = expectedNotificationLevel;
		ADM_UserSettingsController cntroller = new ADM_UserSettingsController(user);
		cntroller.save();
		user = [Select Name,Notification_Level__c,Work_User_Interface__c from user where Id = :user.Id];
		System.assertEquals(expectedNotificationLevel,user.Notification_Level__c);
		System.assertEquals(expectedWorkInterface,user.Work_User_Interface__c);
	}
    
    // Investigation SLAs
    static testMethod void testBusinessHours() {
        ADM_UserSettingsController ctlr;
        ADM_User_Business_Hours__c userBusinessHours;
        
        List<BusinessHours> bhs = [SELECT Id,Name FROM BusinessHours LIMIT 2];
        if (bhs.size() > 0) {
            
            User user = ADM_WorkUser.createTestUser();
            BusinessHours bh1 = bhs.get(0);
            
            // Case 1. Create new UserBusinessHours
            ctlr = new ADM_UserSettingsController(user);
            ctlr.userBusinessHours.Business_Hours__c = bh1.Id;
            ctlr.save();
            
            System.assertNotEquals(null, ctlr.userBusinessHours.Id);
            userBusinessHours = [SELECT User__c,Business_Hours__c FROM ADM_User_Business_Hours__c WHERE Id = :ctlr.userBusinessHours.Id];
            System.assertEquals(user.Id, userBusinessHours.User__c);
            System.assertEquals(bh1.Id, userBusinessHours.Business_Hours__c);
        
            if (bhs.size() > 1) {
                BusinessHours bh2 = bhs.get(1);
                
                // Case 2. Load & Update UserBusinessHours
                ctlr = new ADM_UserSettingsController(user);
                System.assertEquals(bh1.Id, ctlr.userBusinessHours.Business_Hours__c);
                
                ctlr.userBusinessHours.Business_Hours__c = bh2.Id;
                ctlr.save();
                
                System.assert(ctlr.userBusinessHours.Id != null);
                userBusinessHours = [SELECT User__c,Business_Hours__c FROM ADM_User_Business_Hours__c WHERE Id = :ctlr.userBusinessHours.Id];
                System.assertEquals(user.Id, userBusinessHours.User__c);
                System.assertEquals(bh2.Id, userBusinessHours.Business_Hours__c);
            }
            
            // Case 3. Delete UserBusinessHours
            ctlr = new ADM_UserSettingsController(user);
            if (bhs.size() > 1) {
                System.assertEquals(bhs.get(1).Id, ctlr.userBusinessHours.Business_Hours__c);
            } else {
                System.assertEquals(bh1.Id, ctlr.userBusinessHours.Business_Hours__c);
            }
            
            ctlr.userBusinessHours.Business_Hours__c = null;
            ctlr.save();
            
            List<ADM_User_Business_Hours__c> ubhs = [SELECT User__c,Business_Hours__c FROM ADM_User_Business_Hours__c WHERE Id = :ctlr.userBusinessHours.Id];
            System.assertEquals(0, ubhs.size());
        }
    }
}