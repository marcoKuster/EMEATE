@IsTest
public with sharing class ADM_NotifierComponentTests { 

	    
    /*
	@testcaseID a1DB00000000jjn
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.Edit Page
	@expected results Users who were subscribed to Work before the deployment still receive notifications after the deployment without them doing anything.
	@author: James Hatton
     */
	
	static testMethod void testExistingSubscribersAreLoaded() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
        ws.WorkId__c = work.id;
        ws.UserId__c = UserInfo.getUserId();
        insert ws;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        
        System.assert(wc.HiddenReps != null);
        
        System.assert(wc.HiddenReps.contains(UserInfo.getName()));   
    }
    
    /*
	@testcaseID a1DB00000000jjh
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results Auto-complete should recognized the full name when the user is active
	@author: James Hatton
     */
    static testMethod void testSubscribersCanBeCreatedByName() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	
    	User u = ADM_WorkUser.createTestUserWithRandomName(); 
    	
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + u.FirstName + ' ' + u.LastName;
        wc.HiddenReps = encoded;
        //save - subscriber should be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Encoded:' + encoded);
        System.assertEquals(u.id, subs.get(0).UserId__c);
    	
    }
    
        
    /*
	@testcaseID a1DB00000000jjd
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results Notifications with emails ending in @salesforce.com will be added and recipients will be sent an email
	@author: James Hatton
     */
    static testMethod void testSubscribersCanBeCreatedByInternalEmailAddress() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + 'gusteam@salesforce.com';
        wc.HiddenReps = encoded;
        //save - subscriber should be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Encoded:' + encoded);
        System.assertEquals('gusteam@salesforce.com', subs.get(0).Distribution_List__c);
    	
    }
    
   
    
        
    /*
	@testcaseID a1DB00000000jje
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results Notifications with emails ending in @contractor.salesforce.com will be added and recipients will be sent an email
	@author: James Hatton
     */
    static testMethod void testSubscribersCanBeCreatedByInternalContractorEmailAddress() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + 'jsmith.contractor@salesforce.com';
        wc.HiddenReps = encoded;
        //save - subscriber should be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Encoded:' + encoded);
        System.assertEquals('jsmith.contractor@salesforce.com', subs.get(0).Distribution_List__c);
    	
    }
    
        
    /*
	@testcaseID a1DB00000000jjk
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results Notifications with external emails will not be recognized
	@author: James Hatton
     */
    static testMethod void testSubscribersCanNotBeCreatedByExternalEmailAddress() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + 'gusteam@gmail.com';
        wc.HiddenReps = encoded;
        //save - subscriber should NOT be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was NOT created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs == null || subs.size() == 0);
    	
    }
    
        /*
	@testcaseID a1DB00000000lkQ
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results The user is added regardless of whether the name is upper or lower case
	@author: James Hatton
     */
    static testMethod void testSubscribersAreNotCaseSensitive() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	
    	User u = ADM_WorkUser.createTestUserWithRandomName(); 
    	
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + u.FirstName.toLowerCase() + ' ' + u.LastName.toUpperCase();
        wc.HiddenReps = encoded;
        //save - subscriber should be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Encoded:' + encoded);
        System.assertEquals(u.id, subs.get(0).UserId__c);
    	
    }
    
        
    /*
	@testcaseID a1DB00000000jjz
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results Notifications get saved from the assignment rule getting fired from the PA/MFA combo
	@author: James Hatton
     */
    static testMethod void testAuthorIsAutoSubscribed() {
    	Test.startTest();
    	//User u = ADM_WorkUser.createTestUserWithRandomName();
    	
    	//System.runAs(u) {
    	
	    	ADM_Work__c work = ADM_Work.setupTestWork('User Story');
	    	//need to populate a few more fields
	    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
	    	work.Priority__c = 'P1';
	    	
	    	//work is brand new so author should be autosubscribed 
	        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
	        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
	        
	        System.assert(wc.HiddenReps != null);
	        System.assert(wc.HiddenReps.contains(UserInfo.getName()));   
	        
	        //save - subscriber should be inserted
	        wc.saveAndView();
	        Test.stopTest();
	        //verfiy subscriber was created
	        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
	        System.assert(subs != null);
	        //verfiy author is subscribed 
	        Boolean found = false;
	        for(ADM_Work_Subscriber__c s : subs) {
	        	if(s.UserId__c == UserInfo.getUserId()) {
	        		found = true;
	        	}
	        }
	        System.assertEquals(true, found, 'Author was not auto subscribed. Subscribers:' + subs + ' User running test:' + UserInfo.getUserId() + ' ' + UserInfo.getName() + ' Hidden Recipients:' + wc.HiddenReps);
    	//}     
       
    }
    
        
    /*
	@testcaseID a1DB00000000jjc
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results The other emails will be automatically added to the notifications list
	@author: James Hatton
     */
    static testMethod void testEmailsFromAssignmentRulesAreSubscribed() {
    	Test.startTest();
    	//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        //Now Assignment rule trigger expect user for every email address so creating a test user
		User gusTestUser = ADM_WorkUser.setupTestUser();
        gusTestUser.Email = 'gusteam@salesforce.com';
        insert gusTestUser;
    	//create rule
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam(String.valueOf(Math.random())).id;
         rule.Additional_Emails__c = 'gusteam@salesforce.com';
         rule.Product_Owner__c = UserInfo.getUserId();
         rule.Assignee_Assignment__c = UserInfo.getUserId();
         insert rule;
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
        insert tagAssignment;
    	
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	work.Product_Tag__c = productTag.Id;
    	
    	
    	//need to set clone var so that our pre-populated work object is used
    	System.currentPageReference().getParameters().put('clone', '1');
    	
    	//work is brand new so author should be autosubscribed 
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        
        //prioirty is reset on clones 
        wc.setPriority('P1');
                        
        //apply assignment rule
        wc.getAutoAssignedWork();
        
        //verify it was applied        
        System.assert(wc.HiddenReps != null);
      
        //email from rule should be there
         System.assert(wc.HiddenReps.contains(rule.Additional_Emails__c), ' Expected rep:' + wc.HiddenReps + ' to include email:' + rule.Additional_Emails__c + ' work:' + wc.getWork() +  ' rule:' + rule);   
        
        
        //save - subscriber(s) should be inserted
        wc.saveAndView();
        Test.stopTest();
        
        //verfiy subscribers were created according to the Notifier controller
        //init controller
        ADM_NotifierController nc = new ADM_NotifierController();
        nc.work = work;
        System.assert(nc.getSubscribers() != null);
        
        //verfiy subscriber(s) was created by going straight to the DB
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :wc.getWork().Id];
        System.assert(subs != null);
        //verfiy rule additional emails is subscribed 
        Boolean found = false;
        for(ADM_Work_Subscriber__c s : subs) {
        	if(s.Distribution_List__c != null && s.Distribution_List__c == rule.Additional_Emails__c) {
        		found = true;
        	}
        }
        System.assertEquals(true, found, 'Additional Emails from assignment rule were not auto subscribed.  Expected this email to be subscribed:' + rule.Additional_Emails__c + ' Subscribers:' + subs + ' Reps:' + wc.HiddenReps + 'wc.work:' + wc.getWork() + ' local work:' +  ' local work.id:' + work.id);
       
    }
    
        
    /*
	@testcaseID a1DB00000000jjY
	@userstoryID a07B0000000DmOt
	@hierarchy GUS.BugforcetoGUS.Work.Notifications.New Page
	@expected results The creator of the work item gets auto-subscribe to the item
	@author: James Hatton
     */
    static testMethod void testStandardRecipientsAreDisplayed() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	work.Assignee__c = UserInfo.getUserId();
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //init controller
        ADM_NotifierController nc = new ADM_NotifierController();
        nc.work = work;
        String recipients = nc.getStandardRecipients();
        Boolean foundAssignee = false;
        //test is limited to assignee by the user fields populated by the createWork() factory method which is intern limited by gov limits due to 25 lookups
        if(recipients.contains(UserInfo.getName())) {
    		foundAssignee = true;
    	}
        System.assertEquals(true, foundAssignee, 'Did not find Assignee:' + UserInfo.getName() + ' in recipient list:' + recipients);
        
    }
    
    static testMethod void testNotifierController() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	work.Assignee__c = UserInfo.getUserId();
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //init controller
        ADM_NotifierController nc = new ADM_NotifierController();
        nc.setSObjectWork((SObject)work);
        System.assertEquals(work.Id, nc.getSObjectWork().Id);	
    	
    }
    
    /*
	@testcaseID a1DB00000000jjb
	@userstoryID a07B0000000LfHY
	@hierarchy GUS.BugforcetoGUS.Work Page.Notifications.Edit Page
	@expected results The distro list shows on notifications list and sends the work item email to the correct distro
     */
	
    /*
	@expected results Notifications with external emails will not be recognized
	@author: Chris Copek
     */
    static testMethod void testWorkControllerGivesErrorOnInvalidEmailAddress() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	//need to populate a few more fields
    	work.Found_In_Build_Copy__c = work.Found_in_Build__r.Name;
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String invalidEmail = 'test&lt;&gt;@salesforce.com';
        String encoded = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + invalidEmail;
        wc.HiddenReps = encoded;
        //save - subscriber should NOT be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was NOT created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :work.id];
        System.assert(subs == null || subs.size() == 0, 'Expected no subscribers to be created');
        
        System.assert(ApexPages.hasMessages(), 'Expected an error message to be thrown.');
        
        Boolean foundMessage = false;
        String errorMessages = '';
        for(ApexPages.Message message : ApexPages.getMessages()) {
            String errorMessage = message.getSummary();
            if(errorMessage.equals('test<>@salesforce.com is not a valid email address on other recipients.')) {
            	foundMessage = true;
            }
            errorMessages += errorMessage + '\n';
        }
        System.assert(foundMessage, 'Did not get an error message when the email address on the other recipient field is invalid. Actual: ' + errorMessages);
    }

}