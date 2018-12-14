@isTest
public class ADM_WorkEmailControllerTest {

    @isTest
	static void testSendNotificationEmail() {
		ADM_Work__c work1 = ADM_Work.createTestWork();
		ADM_Work__c work2 = ADM_Work.createTestWork();
		work2.Subject__c = 'My Subject has been edited';
		Database.update(work2);

		List<ADM_ChangeListMessage.Recipient> recipients = new List<ADM_ChangeListMessage.Recipient>();
		recipients.add(new ADM_ChangeListMessage.Recipient('jhatton@salesforce.com', 'jhatton@salesforce.com'));

        Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Email Content:', 'Test Content');

		String subjectLine = 'Test Email';

		List<ADM_Comment__c> comments = new List<ADM_Comment__c>();

		User currentUser = [select id, FirstName, LastName, Name from user limit 1];

		ADM_ChangeListMessage message = new ADM_ChangeListMessage(coreValues, recipients, subjectLine, comments, currentUser);

        //if message is successfully sent true is returned
		System.assert(ADM_WorkEmail.sendNotification(message));

	}

    @isTest
    public static void testSendNotification(){
        User tempUser = ADM_WorkUser.createTestUser();
        User user1 = [SELECT id, Name from User where ID = :tempUser.Id];

        String subjectValue = 'The subject field in the work item email body\'s contents is not being escaped properly<div style="font-size:5cm;font-weight:bold;color:#663366;">You\'ve been 0wn3d ;-)!</div>';

        Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Subject', subjectValue);
        coreValues.put('Link', ADM_WorkUtils.GUS_URL + '/a07B0000000OJv2');

        List<String> toAddresses = new List<String>();
        toAddresses.add('test@gus.test');
         toAddresses.add('test@gus.test');
        toAddresses.add('anotherTest@gus.test');

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('anotherTest@gus.test');
        ADM_Comment__c [] comments = null;

        List< String > changeList = new List< String >();
        Boolean b = ADM_WorkEmail.sendNotification(coreValues, changeList, toAddresses,  ccAddresses,  subjectValue, comments, user1);
		System.assert(b,false);
    }


}