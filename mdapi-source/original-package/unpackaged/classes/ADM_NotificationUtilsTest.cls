@isTest
public with sharing class ADM_NotificationUtilsTest {
	testMethod static void testEncodeEmailToLineWithString() {
		User user1 = ADM_WorkUser.createTestUser();
		
		User user2 = ADM_WorkUser.createTestUser();
		user2 = [select Id, Name, Alias from User where Id=:user2.Id];
		user2.Alias = 'jaredp';
		update user2;
		
		String emailTo = user1.Email + ' ' + user2.Alias;
		
		Test.startTest();
		List<ADM_Work_Subscriber__c> subscribers = ADM_NotificationUtils.convertEmailToLineToWorkSubscriberObjects(emailTo);
		Test.stopTest();
		
		System.assert(subscribers != null, 'convertEmailToLineToWorkSubscriberObjects should never return null');
		System.assertEquals(2, subscribers.size(), 'Expecting to find the subscriber for the given ID string');
	}
	
	testMethod static void testRemoveAutoAssignedRecipients() {
		
		String actual = ADM_NotificationUtils.removeAutoAssignedRecipients('M==jaredp::A=rickdeckard@salesforce.com');
		
		System.assert(actual.contains('M==jaredp'), 'Expected the manually added recipient to remain');
		System.assert(actual.contains('A==rickdeckard@salesforce.com') == false, 'Expected the automatically added recipient to be removed');
	}
}