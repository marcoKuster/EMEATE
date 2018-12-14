@IsTest
public with sharing class ADM_ChangeListMessageTest {
	
	static testMethod void formatChangeListMessageWithHtml() {
        User user1 = ADM_WorkUser.createTestUser();
        
        String subjectValue = 'The subject field in the work item email body\'s contents is not being escaped properly<div style="font-size:5cm;font-weight:bold;color:#663366;">You\'ve been 0wn3d ;-)!</div>';

        Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Subject', subjectValue);
        coreValues.put('Link', ADM_WorkUtils.GUS_URL + '/a07B0000000OJv2');
        
        List<ADM_ChangeListMessage.Recipient> toAddresses = new List<ADM_ChangeListMessage.Recipient>();
        toAddresses.add(new ADM_ChangeListMessage.Recipient('test@gus.test', 'test@gus.test'));
        toAddresses.add(new ADM_ChangeListMessage.Recipient('anotherTest@gus.test', 'anotherTest@gus.test'));
        ADM_Comment__c [] comments = null;
        ADM_ChangeListMessage clm = new ADM_ChangeListMessage(coreValues, toAddresses, subjectValue, comments, user1);
        Messaging.SingleEmailMessage singleEmailMessage = clm.toEmailMessage();

        String htmlBody = singleEmailMessage.getHtmlBody();
        
        System.assert(htmlBody.contains('The subject field in the work item email body&#39;s contents is not being escaped properly&lt;div style=&quot;font-size:5cm;font-weight:bold;color:#663366;&quot;&gt;You&#39;ve been 0wn3d ;-)!&lt;&#47;div&gt;'), 'Expected the HTML body to be escaped.\nActual:\n' + htmlBody);
    }
    
    static testMethod void testFormatComment() {
        User user1 = ADM_WorkUser.createTestUser();
        String subjectValue = 'Subject';

        Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Subject', subjectValue);
        coreValues.put('Link', 'http://gus.salesforce.com/a07B0000000OJv2');
        
        List<ADM_ChangeListMessage.Recipient> toAddresses = new List<ADM_ChangeListMessage.Recipient>();
        toAddresses.add(new ADM_ChangeListMessage.Recipient('test@gus.test', 'test@gus.test'));
        toAddresses.add(new ADM_ChangeListMessage.Recipient('anotherTest@gus.test', 'anotherTest@gus.test'));
        
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>{
        	new ADM_Comment__c(Body__c = 'Comment1\nasdf\n\tasdf', Preserve_Formatting__c = false),
            new ADM_Comment__c(Body__c = 'Comment2\nasdf\n\tasdf', Preserve_Formatting__c = true),
            new ADM_Comment__c(Body__c = '<b>Test</b>', Preserve_Formatting__c = false)
        };
        ADM_ChangeListMessage clm = new ADM_ChangeListMessage(coreValues, toAddresses, subjectValue, comments, user1);
        Messaging.SingleEmailMessage singleEmailMessage = clm.toEmailMessage();
        String strReturnHTML = singleEmailMessage.getHtmlBody();
        
        System.assert(strReturnHTML.contains('Comment1<br />asdf<br />&nbsp;&nbsp;&nbsp;&nbsp;asdf'), 'Expecting the first comment to be formatted as HTML');
        System.assert(strReturnHTML.contains('Comment2\nasdf\n\tasdf'), 'Expecting the second comment to be formatted as entered because Preserve Formatting is set');
        System.assert(strReturnHTML.contains('&lt;b&gt;Test&lt;/b&gt;'), 'Expecting the third comment to be HTML escaped');
    }
    
    static testMethod void testLargeValuesGetTruncated() {
    	Integer MAX_SIZE = 3200;
        User user1 = ADM_WorkUser.createTestUser();
        String subjectValue = 'Subject';

        Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Subject', subjectValue);
        coreValues.put('Link', 'http://gus.salesforce.com/a07B0000000OJv2');
        
        //create a comment that is over 3200 characters
        String largeDetails = '';
        while(largeDetails.length() <= MAX_SIZE + 10) {
        	largeDetails += 'a';
        }
        coreValues.put('Details and Steps to Reproduce', largeDetails);
        
        List<ADM_ChangeListMessage.Recipient> toAddresses = new List<ADM_ChangeListMessage.Recipient>();
        toAddresses.add(new ADM_ChangeListMessage.Recipient('test@gus.test', 'test@gus.test'));
        toAddresses.add(new ADM_ChangeListMessage.Recipient('anotherTest@gus.test', 'anotherTest@gus.test'));
        
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>();
        
        ADM_ChangeListMessage clm = new ADM_ChangeListMessage(coreValues, toAddresses, subjectValue, comments, user1);
        Messaging.SingleEmailMessage singleEmailMessage = clm.toEmailMessage();
        String longTestMessage = 'See the rest of Details and Steps to Reproduce on the work record.';
        String actualMessage = '... <br /><br />' + longTestMessage;//changed it to html line break
        Integer messageIndex = -1;
        
        //get the message from the email and check the message length
        String strReturnHTML = singleEmailMessage.getHtmlBody();
        System.debug('Actual HTML Body:\n' + strReturnHTML);
        messageIndex = strReturnHTML.indexOf(actualMessage);
        String actualHtmlMessage = strReturnHTML.substring(strReturnHTML.lastIndexOf('>', messageIndex) + 1, messageIndex);
        System.assert(messageIndex > -1, 'Expecting the large value in the HTML email body to be truncated.');
        System.assertEquals(MAX_SIZE, actualHtmlMessage.length(), 'Expected the value of the message to be truncated to ' + MAX_SIZE + ' characters.');
        
         //get the message from the email and check the message length
        String strReturnText = singleEmailMessage.getPlainTextBody();
        System.debug('Actual Text Body:\n' + strReturnText);
        actualMessage = '... \n\nSee the rest of Details and Steps to Reproduce on the work record.';
        messageIndex = strReturnText.indexOf(actualMessage);
        String actualTextMessage = strReturnText.substring(strReturnText.lastIndexOf(' ', messageIndex) + 1, messageIndex);
        System.debug(actualTextMessage);
        System.assert(messageIndex > -1, 'Expecting the large value in the Text email body to be truncated.');
        System.assertEquals(MAX_SIZE, actualTextMessage.length(), 'Expected the value of the message to be truncated to ' + MAX_SIZE + ' characters.');
    }
    
    static testMethod void testEmailOnChatterPost() {
    	
    	ADM_Work__c newWork = ADM_Work.createTestWork();
    	
    	FeedItem testFeed1 = new FeedItem();
    	testFeed1.Body = 'Test feed1 for apex test';
    	testFeed1.ParentId = newWork.Id;
    	insert testFeed1;
    	
    	FeedItem testFeed2 = new FeedItem();
    	testFeed2.Body = 'Test feed2 for apex test';
    	testFeed2.ParentId = newWork.Id;
    	insert testFeed2;
    	
    	List<FeedItem> feeds = new List<FeedItem>();
    	feeds.add(testFeed1);
    	feeds.add(testFeed2);
    	
        String subjectValue = 'Subject';
        
    	Map<String, String> coreValues = new Map<String, String>();
        coreValues.put('Subject', subjectValue);
        coreValues.put('Link', 'http://gus.salesforce.com/a07B0000000OJv2');
        
        List<ADM_ChangeListMessage.Recipient> toAddresses = new List<ADM_ChangeListMessage.Recipient>();
        toAddresses.add(new ADM_ChangeListMessage.Recipient('test@gus.test', 'test@gus.test'));
        toAddresses.add(new ADM_ChangeListMessage.Recipient('anotherTest@gus.test', 'anotherTest@gus.test'));
        
        
    	ADM_ChangeListMessage clm = new ADM_ChangeListMessage(coreValues, toAddresses, subjectValue, feeds, ADM_WorkUser.get(UserInfo.getUserId())); 
    	
    	Messaging.SingleEmailMessage singleEmailMessage = clm.toEmailMessage();
    	
    	System.assert(singleEmailMessage.getPlainTextBody().contains('Test feed1 for apex test'));
    	System.assert(singleEmailMessage.getPlainTextBody().contains('Test feed2 for apex test'));
    }
    
}