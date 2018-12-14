/**
 *    @userstory W-1224650: eRelease Request process takes up too many workflows
 */

/*
 * Email Utility test class from
 * http://developer.force.com/cookbook/recipe/email-utility-class
 * with updates from
 * http://boards.developerforce.com/t5/Apex-Code-Development/Behavior-testing-a-sendEmail-statement/m-p/284331/highlight/false#M49675
 */

@isTest
private class COM_EmailUtilsTests {

    /* ===================================
        Tests:
    ======================================= */

    private static testMethod void should_work_with_templates() {
        // Given an email util that has not sent emails, and a template for emails
        System.assertEquals(null, COM_EmailUtils.last_sendEmail_result);

        Folder test_template_folder;
        try {
            test_template_folder =
            [Select Id from Folder Where Type = 'Email' And IsReadOnly = false Limit 1];
        } catch (Exception e) {
        	// no Folder; abort test
        	System.debug('should_work_with_templates: no Public, Writeable, Email Communication Template Folder could be found; aborting test.');
        	return;
        }

        EmailTemplate test_template = new EmailTemplate(
            Name = 'test email template', DeveloperName = 'test_template_unique',
            TemplateType = 'text', isActive = true, Description = 'test template',
            Subject = 'test email', FolderId = test_template_folder.Id,
            Body = 'Hi {!Receiving_User.FirstName}, this is a test email to a user.'
        );
        insert test_template;

        // When an email is constructed & sent to the current user with that template
        COM_EmailUtils.to(UserInfo.getUserId())
            .templateId(test_template.Id)
            .sendEmail();

        // Then it should be sent successfully
        System.assertEquals(1, COM_EmailUtils.last_sendEmail_result.size());
        for (Messaging.SendEmailResult ser : COM_EmailUtils.last_sendEmail_result)
            System.assertEquals(true, ser.isSuccess());
    }

    private static testMethod void should_bulk_stash() {
        // Given an COM_EmailUtils that doesn't have emails to send.
        System.assertEquals(false, COM_EmailUtils.hasEmailsToSend());

        // When you stash an email to send
        COM_EmailUtils.to(new String[]{'test@example.com'})
            .stashForBulk();

        // Then COM_EmailUtils should have emails to send
        System.assertEquals(true, COM_EmailUtils.hasEmailsToSend());
    }


    private static testMethod void should_gracefully_handle_empty_bulk_send() {
        // Given an COM_EmailUtils with no emails to send
        System.assertEquals(false, COM_EmailUtils.hasEmailsToSend());

        try {
            // When you try and do a bulk send
            COM_EmailUtils.sendBulkEmail();
        } catch (Exception e) {
            // then it shouldn't fail horribly.
            System.assert(false);
        }
    }

    private static testMethod void setters_should_not_throw_exceptions() {
        try {
        	User currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
            // When using all the setters
            COM_EmailUtils.to(new String[]{currentUser.email})
                .saveAsActivity(false)
                .senderDisplayName('test sender')
                .subject('test email')
                .htmlBody('this is html')
                .useSignature(false)
                .replyTo(currentUser.email)
                .plainTextBody('this is plaintext')
                .fileAttachments(null);
        } catch (Exception e) {
            // Then it should not throw an exception.
            system.assert(false);
        }
    }
    private static testMethod void test_dedup() {
        String rval;

        String test1 = 'test@example.org,test@example.com,test@example.org,test@example.net';
        String result1 = 'test@example.org,test@example.com,test@example.net';
        rval=COM_EmailUtils.dedup(test1);
        System.assert(rval.compareTo(result1) == 0, 'COM_EmailUtils: dedup test 1 string="' + test1 + '" Expected="' + result1 + '" but result was="' + rval + '"');

        String test2 = 'test@example.com,test@example.com,test@example.org,test@example.org';
        String result2 = 'test@example.com,test@example.org';
        rval=COM_EmailUtils.dedup(test2);
        System.assert(rval.compareTo(result2) == 0, 'COM_EmailUtils: dedup test 2 string="' + test2 + '" Expected="' + result2 + '" but result was="' + rval + '"');

        String test3 = 'test@example.org,test@example.org,test@example.org';
        String result3 = 'test@example.org';
        rval=COM_EmailUtils.dedup(test3);
        System.assert(rval.compareTo(result3) == 0, 'COM_EmailUtils: dedup test 1 string="' + test3 + '" Expected="' + result3 + '" but result was="' + rval + '"');

        rval=COM_EmailUtils.dedup('');
        System.assert(rval.length() == 0, 'COM_EmailUtils: dedup test 4 string=Empty String Expected="' + '' + '" but result was="' + rval + '"');

    }
}