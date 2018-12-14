@IsTest
public class ADM_Email2GUSTest {

    /**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B200000033mZjEAI
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults Create a new bug in GUS. Save. Reply to email sent and add some comments. The email will have a reply to address that looks like this: 'email2gus@50tqzyo1qz3p37ul1m25owwyb.in.sandbox.salesforce.com'. This address is an encrypted token that gets assigned with every new bug
  */
    @IsTest
    static void testEmail2GUS() {
     String commentHeader = 'Comments submitted via email2apex:\n\n';
     String myBody = 'This is a one line body\n';

     Messaging.InboundEmail email = new Messaging.InboundEmail();
     ADM_Work__c work = ADM_Work.createTestWork();
     ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
     User user = ADM_WorkUser.get(work.Assignee__c);
     email.subject = '#' + insertedWork.Name + ' - This is a test subject';
     email.plainTextBody = myBody;
     email.fromaddress = user.email;
     Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
     try {
         ADM_Email2GUS e2g = new ADM_Email2GUS();
         Test.startTest();
         Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
         Test.stopTest();
         System.assert(result != null);
         ADM_Comment__c[] comments = [Select a.Body__c,LastModifiedById From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
         
         
         
         System.assert(comments[0].Body__c.equals(commentHeader + myBody.trim()));
     } catch (Exception e) {
         
         System.assert(false);
     }
 }

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPgSEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults Update does not complete.  Bounced back to original sender.
  */

    @IsTest
    static void testNoSubjectEmail2GUS() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = '';
        User user = [select id, email from user limit 1];
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            
            System.assert(result.success == false);

        } catch (Exception e) {
            
            System.assert(false);
        }

    }

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPlNEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults Update does not complete.  Bounced back to original sender.
  */

    @IsTest
    static void testBadSubjectEmail2GUS() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = [select Name from ADM_Work__c where Id =: work.Id];
        email.subject = '#AAA' + insertedWork.Name + ' This is a test subject';
        User user = [select id, email from user limit 1];
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            System.assert(result.success == false);

        } catch (Exception e) {
            
            System.assert(false);
        }

    }

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnAEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */

    @IsTest
    static void testUnableToMatchFromEmail2GUS() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = [select Name from ADM_Work__c where Id =: work.Id];
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        User user = [select id, email from user limit 1];
        email.fromaddress = 'A' + user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            System.assert(result != null);

        } catch (Exception e) {
            
            System.assert(false);
        }

    }

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnUEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */

    @IsTest
    static void testOutlookStripPreviousCommentsEmail2GUS () {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'New comments\n' +
                        '\n' +
                        'From: A user\n' +
                        'Old comments to remove';
        String expectedComment = 'New comments\n\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + expectedComment.trim()));
        } catch (Exception e) {
            
            System.assert(false);
        }
}

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnZEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */

    @IsTest
    static void testBlackberryStripPreviousCommentsEmail2GUS () {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'New comments\n' +
                        '________________________________\n' +
                        'From: A user\n' +
                        'Old comments to remove';
        String expectedComment = 'New comments\n\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + expectedComment.trim()));
        } catch (Exception e) {
            
            System.assert(false, 'Unexpected exception:' + e);
        }
}

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnVEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */
    @IsTest
    static void testRemoveWroteCommentsAfterResponseWithNoStartingCharacterEmail2GUS () {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'New comments\n' +
                        '\n' +
                        'On 07/01/2009 Mickey Mouse wrote:\n' +
                        'Old comments to remove';
        String expectedComment = 'New comments\n\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + expectedComment.trim()));
        } catch (Exception e) {
            
            System.assert(false);
        }
}

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnWEAU
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */

    @IsTest
    static void testThunderbirdStripGreaterThanCommentsEmail2GUS() {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'Analia Mastrogiovanni Test\n' +
                              '>>>>previous reply\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + myBody.trim()));
        } catch (Exception e) {
            
            System.assert(false);
        }
}

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000006aPnjEAE
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */

    @IsTest
    static void testThunderbirdRemoveWroteCommentsAfterResponseEmail2GUS() {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'Analia Mastrogiovanni Test\n' +
                              'The User wrote:\n' +
                              '>> This is a test\n';
        String expectedComment = 'Analia Mastrogiovanni Test\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        
        
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + expectedComment.trim()));
        } catch (Exception e) {
            
            System.assert(false);
        }

    }

/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a0B20000005HTErEAO
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS
  *@userstory a0A200000037nDY
  *@expectedResults TODO.
  */
    @IsTest
    static void testThunderbirdRemoveWroteCommentsBeforeResponseEmail2GUS() {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'Analia Mastrogiovanni wrote: \n' +
                        '>> This is a test previous comment\n' +
                        '>> This is the second line of previous comment\n' +
                        'This is the new response';
        String expectedComment = 'This is the new response';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            System.assert(comments[0].Body__c.equals(commentHeader + expectedComment.trim()));
        } catch (Exception e) {
            
            System.assert(false);
        }

    }
    


/**Reply to a bug with no subject.
   This is the long Description.
  *@testcaseID a1DB000000013tt
  *@hierarchy GUS.BugforceToGUS.SystemIntegrations.Email2GUS.Reply All to bug
  *@userstory a07B0000000DyQsIAK
  *@expectedResults Hitting Reply will send one email to all assignees and users in "Other Recipients" in the Work record, plus any other users the replier might choose to add in the email. Also, the comments will be added to the work record in GUS once
  */
    @IsTest
    static void testOLimitDuplicateEmailsnReplyAll() { 
        ADM_Work__c insertedWork, work;
        
        Test.startTest();
        work = ADM_Work.createTestWork();
        Test.stopTest();
        
        insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = 'This is a one line body\n';
        email.fromaddress = user.email;
        email.toAddresses = new String[]{'darth.chratis@sith.com','Eldon Ax <eldon.ax@sith.com>'};
        email.ccAddresses = new String[]{'satele.shan@jedi.com','Shigar Konshi <shigar.konshi@jedi.com>'};
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            
            insertedWork = ADM_Work.getOneBy('Id', work.Id);
            System.assertNotEquals('', insertedWork.Email2GUS_Addresses__c);
            System.assert(insertedWork.Email2GUS_Addresses__c.contains('darth.chratis@sith.com'));
            System.assert(insertedWork.Email2GUS_Addresses__c.contains('eldon.ax@sith.com'));
            System.assert(insertedWork.Email2GUS_Addresses__c.contains('satele.shan@jedi.com'));
            System.assert(insertedWork.Email2GUS_Addresses__c.contains('shigar.konshi@jedi.com'));
            System.assertEquals(4, insertedWork.Email2GUS_Addresses__c.split(',').size());
        } catch (Exception e) {
            
            throw e;
        }
    }
    
/*.
  *@testcaseID a1DB00000000Fsl
  *@hierarchy GUS.SystemIntegrations.Email2GUS.Reply to bug
  *@userstory a07B0000000SbCL
  *@expectedResults 
        Email2GUS had a bug where it assumed prior comments could be stripped by checking for line starting with 'On' and ending with 'wrote' such as:
        
        "On Fri, Apr 12, 2013 at 2:43 PM, GUS Email2GUS <gusteam@salesforce.com>wrote:"
        
        However sometimes this string can wrap into two lines such as:
        
        "On Fri, Apr 12, 2013 at 1:40 PM, PATCHTEST Mastro SYSADM <
        btest19@wilikihanatest.com> wrote:"
        
        This test will catch this bug if it is ever regressed
    
    */
    
    @IsTest
    static void testGmailRemoveCommentsAfterResponseEmail2GUS() {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'my test comment\n' +
                        'On Fri, Apr 12, 2013 at 1:40 PM, PATCHTEST Mastro SYSADM < \n' +
                        'btest19@wilikihanatest.com> wrote:"\n';
        String expectedComment = 'my test comment\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        
        
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            String finalComment = commentHeader + expectedComment.trim();
            String actualComment = comments[0].Body__c;  
            System.assertEquals(finalComment, actualComment);
        } catch (Exception e) {
            
            System.assert(false);
        }

    }
    
    /*.
  *@testcaseID a1DB00000000Fsl
  *@hierarchy GUS.SystemIntegrations.Email2GUS.Reply to bug
  *@userstory a07B0000000SbCL
  *@expectedResults 
        Email2GUS had a bug where the whole email chain would be included if extra carriage returns were added to the email. For example:
        
        "On Fri, Apr 12, 2013 at 1:40 PM, PATCHTEST Mastro SYSADM <
        
        btest19@wilikihanatest.com> wrote:"
        
        This test will catch this bug if it is ever regressed
    
    */
    
    @IsTest
    static void testGmailEmail2GUSCommentWithExtraCarriageReturns() {
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        String myBody = 'my test comment\n' +
                        'On Fri, Apr 12, 2013 at 1:40 PM, PATCHTEST Mastro SYSADM < \n' +
                         '\n' +
                        'btest19@wilikihanatest.com> wrote:"\n';
        String expectedComment = 'my test comment\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c insertedWork = ADM_Work.getOneBy('Id', work.Id);
        User user = ADM_WorkUser.get(work.Assignee__c);
        email.subject = '#' + insertedWork.Name + ' - This is a test subject';
        email.plainTextBody = myBody;
        email.fromaddress = user.email;
        
        
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        try {
            ADM_Email2GUS e2g = new ADM_Email2GUS();
            Test.startTest();
            
            Messaging.InboundEmailResult result =  e2g.handleInboundEmail(email, envelope);
            Test.stopTest();
            System.assert(result != null);
            ADM_Comment__c[] comments = [Select a.Body__c From ADM_Comment__c a Where a.Work__c =: work.id Order By a.Comment_Created_Date__c DESC ];
            
            
            String finalComment = commentHeader + expectedComment.trim();
            String actualComment = comments[0].Body__c;  
            System.assertEquals(finalComment, actualComment);
        } catch (Exception e) {
            
            System.assert(false);
        }

    }

}