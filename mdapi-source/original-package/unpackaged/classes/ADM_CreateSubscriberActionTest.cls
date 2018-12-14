@isTest
public class ADM_CreateSubscriberActionTest {

	@isTest    
	static void testBeforeInsertOrUpdate() {	
		ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
		User u = ADM_WorkUser.createTestUser();
		work.Email_Subscription_ID__c = u.Username;
		Boolean emailSubscribersAreValid = ADM_CreateSubscriberAction.beforeInsertOrUpdate(new List<ADM_Work__c>{work}); 
		
		System.assertEquals(true, emailSubscribersAreValid);
		System.assertEquals(false, ApexPages.hasMessages());
		
		//repeat test with invalid email subscription
		work.Email_Subscription_ID__c = 'sfdfadsfdsf';
		emailSubscribersAreValid = ADM_CreateSubscriberAction.beforeInsertOrUpdate(new List<ADM_Work__c>{work});  
		System.assertEquals(false, emailSubscribersAreValid);
		System.assertEquals(true, ApexPages.hasMessages());

	}

}