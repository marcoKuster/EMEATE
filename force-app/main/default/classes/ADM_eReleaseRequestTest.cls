/*
 * This focus of this test is the eReleaseRequestTrigger, which send email alerts
 * when the status of eRelease Request objects change.  So this test needs to 
 * create all of: an Application object, the Application Approver lists, and the ERR for that Application.
 * When this ERR is inserted into the database, the trigger will be invoked. 
 *
 *    @testcaseID eReleaseRequestTest
 *    @hierarchy TO BE ADDED
 *    @userstory W-1224650 https://gus.salesforce.com/a07B0000000LyH4IAK
 *    @author snahm
 */

@isTest
private class ADM_eReleaseRequestTest {


    /**
     * When an existing ERR recorded is cloned, the Released In, Checkin Details and
     * Additional Instructions fields should all be reset.
     * 
     * @userStory W-2036167
     * @hierarchy TBD
     * @priority Medium
     */
    static testMethod void testClonedFieldsCleared() {
  
  		final String TEST_CHECKIN_DETAILS = '//checkin/here/.. with build test.123';
  		final String TEST_ADDITIONAL_INSTRUCTIONS = 'Call Release Manager for details';
  		final String TEST_RELEASE_NAME = 'Test Release 123';
     
     	ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', false);
		eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);
		
		// Set request as Approved, then retrieve record to note the state of the fields
		ADM_Release__c release = ADM_Release.createTestRelease(TEST_RELEASE_NAME, app);
		err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
		err.Checkin_Location__c = TEST_CHECKIN_DETAILS;
		err.Release_Team_Comments__c = TEST_ADDITIONAL_INSTRUCTIONS;
		err.Released_In__c = release.Id;
     	Database.update(err);
     	
     	err = [select eRelease_Status__c, Checkin_Location__c,Release_Team_Comments__c,
     		Customer_Impact__c, Explanation_of_eRelease__c, Requested_Deployment_Date__c,
     		Released_In__c,Released_In__r.Name from eRelease_Request__c where Id =: err.Id][0];	
     	System.assert(err.eRelease_Status__c.equals(ADM_eReleaseRequest.ERR_APPROVED), 
     		'testClonedFieldsCleared: Wrong ERR state after updating status to ' + ADM_eReleaseRequest.ERR_APPROVED);
		System.assert(err.Checkin_Location__c.equals(TEST_CHECKIN_DETAILS), 
     		'testClonedFieldsCleared: Wrong ERR Checkin Details after updating status to ' + ADM_eReleaseRequest.ERR_APPROVED);
     	System.assert(err.Release_Team_Comments__c.equals(TEST_ADDITIONAL_INSTRUCTIONS), 
     		'testClonedFieldsCleared: Wrong ERR Additional Details after updating status to ' + ADM_eReleaseRequest.ERR_APPROVED);
     	System.assert(err.Released_In__r.Name.equals(TEST_RELEASE_NAME), 
     		'testClonedFieldsCleared: Wrong ERR Release Name after updating status to ' + ADM_eReleaseRequest.ERR_APPROVED);		     	
     
     	eRelease_Request__c cloneErr = err.clone();
     	System.Debug('testClonedFieldsCleared: err=' + err);
     	System.Debug('testClonedFieldsCleared: cloneErr=' + cloneErr);
     	Database.insert(cloneErr);

		cloneErr = [select eRelease_Status__c, Checkin_Location__c,Release_Team_Comments__c,
     		Customer_Impact__c, Explanation_of_eRelease__c, Requested_Deployment_Date__c,
     		Released_In__c,Released_In__r.Name from eRelease_Request__c where Id =: cloneErr.Id][0];	     
     	System.assert(cloneErr.eRelease_Status__c.equals(ADM_eReleaseRequest.ERR_PENDING), 
     		'testClonedFieldsCleared: Wrong ERR state after cloning ERR - is: ' + cloneErr.eRelease_Status__c 
     		+ ' Should be: ' + ADM_eReleaseRequest.ERR_PENDING);
      	System.assert(cloneErr.Release_Team_Comments__c == null || !cloneErr.Release_Team_Comments__c.equals(TEST_ADDITIONAL_INSTRUCTIONS), 
     		'testClonedFieldsCleared: Additional Instructions field was not reset after clone - is:  ' + cloneErr.Release_Team_Comments__c);
      	System.assert(!cloneErr.Checkin_Location__c.equals(TEST_CHECKIN_DETAILS), 
     		'testClonedFieldsCleared: Additional Instructions field was not reset after clone - is:  ' + cloneErr.Checkin_Location__c);     		
    }

    static testMethod void testEmailTemplates() {

        // The Email template requires a $CurrentPage reference
        PageReference pageRef = new PageReference('https://gus.salesforce.com');
        Test.setCurrentPage(pageRef);

        List<User> nu = ADM_ApplicationApprover.createTestUsers();
        // nu[0] will be the primary RM
        // nu[1] will be the secondary RM
        // nu[2] is not used
            
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);

        /* DEBUG OFF  System.debug('ID of Work: ' + work.id);   /* DEBUG */
 
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', nu[0], nu[1]);
        app = [select Primary_Release_Manager__c,Secondary_Release_Manager__c from ADM_Application__c where Id= :app.id];
        
        /* DEBUG OFF  System.debug('App: ' + app);    /* DEBUG */    
                    
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);
 
        // Test 1: Trigger should have set up the template IDs
        System.assert(ADM_eReleaseRequestEmailTemplateIds.templatePendingId != null);
        System.assert(ADM_eReleaseRequestEmailTemplateIds.templateApprovedId != null);
        System.assert(ADM_eReleaseRequestEmailTemplateIds.templateRejectedID != null);
        System.assert(ADM_eReleaseRequestEmailTemplateIds.templateNMIId != null);
        System.assert(ADM_eReleaseRequestEmailTemplateIds.templateWithdrawnId != null);
    }
    
    /**
     * Application with Email disabled.
     * Submit an ERR for an Application that has the Send_Emai_Notifications__c field 
     * set to false.
     * testcaseID a1DB00000002tC4
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */
     
     static testMethod void testApplicationDisabledEmail() {

        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
     
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', false);
        ADM_ApplicationApprover.createTestApplicationApprovers(app);
     
        eRelease_Request__c err = ADM_eReleaseRequest.setupTestEReleaseRequest(work, app, null, null, null);
        
        System.debug('testApplicationDisabledEmail: about to insert err=' + err);
        
        Database.insert(err);
        
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        
        System.assert(sentEmail.size() == 0, 'testApplicationDisabledEmail: No Email should have been sent but number sent was:' + sentEmail.size());
        
     }
     

    /**
     * Application with no Approvers.
     * Submit an ERR for an Application that has the Send_Emai_Notifications__c field 
     * set to true, however there are no Application Approvers associated with this 
     * Application.
     * testcaseID a1DB00000002tCE
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */

     static testMethod void testApplicationNoApprovers() {

        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
     
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', true);
     
        eRelease_Request__c err = ADM_eReleaseRequest.setupTestEReleaseRequest(work, app, null, null, null);
        
        System.debug('testApplicationNoApprovers: about to insert err=' + err);
        
        Database.insert(err);
        
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        
        System.assert(sentEmail.size() == 0, 'testApplicationNoApprovers: No Email should have been sent but number sent was:' + sentEmail.size());
        
     }

    /**
     * Application with One Approver.
     * Submit an ERR for an Application that has the Send_Emai_Notifications__c field 
     * set to true and there is exactly one Application Approvers associated with this 
     * Application.
     * testcaseID a1DB00000002tCJ
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */
    static testMethod void testApplicationOneApprover() {

        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
     
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', true);
        ADM_ApplicationApprover.createTestApplicationApprovers(app);
     
        eRelease_Request__c err = ADM_eReleaseRequest.setupTestEReleaseRequest(work, app, null, null, null);
        
        System.debug('testApplicationDisabledEmail: about to insert err=' + err);
        
        Database.insert(err);
        
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        
        System.assert(sentEmail.size() == 1, 'testApplicationOneApprover: One email should have been sent but number sent was:' + sentEmail.size());
        
     }
    /**
     * Application with multple Approvers.
     * Submit an ERR for an Application that has the Send_Emai_Notifications__c field 
     * set to true and there is at least three Application Approvers associated with 
     * this Application.
     * testcaseID a1DB00000002tCO
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */
     
     static testMethod void testApplicationMultipleApprovers() {
     
        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
     
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', null, null);
        app = [select Enable_ERR_Notification_Emails__c from ADM_Application__c where id =: app.id];  
        app.Enable_ERR_Notification_Emails__c = true;
        update(app);
        
        ADM_ApplicationApprover.createTestApplicationApprovers(app);    // Creates four Application Approvers for this app

        eRelease_Request__c err = ADM_eReleaseRequest.setupTestEReleaseRequest(work, app, null, null, null);
        
        Database.insert(err);
            
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        /* DEBUG ON */ System.debug('testApplicationMultipleApprovers: sentEmail=' + sentEmail);

        System.assert(sentEmail.size() == 1, 'testApplicationMultipleApprovers: One Email should have been sent but number sent was: ' + sentEmail.size());
     }   

    /**
     * Test state transitions that send email.
     * Check each of these transitions:
     * Newly entered ERR -> Pending
     * Pending -> Approved
     * Pending->Rejected
     * Pending->Need More Info
     * Need More Info->Withdrawn
     * Withdrawn->Approved.
     * Approved -> Released.      
     * testcaseID a1DB00000002tCi
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     *
     * Also included below:
     * Test state transitions that do not send email.
     * Check each of these transitions:
     * Pending -> Pending 
     * Approved -> Approved 
     * Need More Info -> Need More Info 
     * Withdrawn -> Withdrawn 
     * Rejected -> Rejected  
     * testcaseID
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */

     static testMethod void testAAStateTransitionsPart1(){
        
        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Pittsburgh', 'Pirates', true);

        /* DEBUG OFF
        System.debug('testStateTransitions: test application is: ' + app);
        /* DEBUG */

        List<User> nu = ADM_ApplicationApprover.createTestUsers();
        // nu[0] is the first sample Application Approver
        // nu[1] and nu[2] are not used
        
        Test.startTest();        
        
        ADM_Application_Approver__c aa = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[0], nu[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_QE);

        //Testing for Newly entered ERR -> Pending        
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);

        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: After ERR insert, Status is Pending - One Email should have been sent but number sent was: ' + sentEmail.size());
        List <String> results = sentEmail[0].getToAddresses();        
        System.assert(results.size() == 1, 'testAAStateTransitions: After ERR insert, Status is Pending - Email should have been sent to one address but was to: ' + results.size());        

        // Testing for Status changed from Pending -> Pending
        mockEmail.resetSentMessages();        
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_PENDING;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages(); 
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Testing Pending -> Pending - Zero Email should have been sent but number sent was: ' + sentEmail.size());

        //Testing for Pending -> Approved & adding new Approvers (Current Count: 2)
        mockEmail.resetSentMessages();        
        ADM_Application_Approver__c aa1 = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[1], nu[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV); 
                    
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages(); 
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: Testing Pending -> Approved, One Email should have been sent but number sent was: ' + sentEmail.size());
        results = sentEmail[0].getToAddresses();        
        System.assert(results.size() == 2, 'testAAStateTransitions: Testing Pending -> Approved, Email should have been sent to two addresses but was sent to: ' + results.size());
        
        //Testing for Approved -> Approved
        mockEmail.resetSentMessages();        
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages(); 
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Testing Approved -> Approved - Zero Email should have been sent but number sent was: ' + sentEmail.size());

        //Testing for Pending -> Rejected & Adding new Approvers (Current Count remains 2, as added Approver is for Releases only)
        mockEmail.resetSentMessages();        
        ADM_Application_Approver__c aa2 = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[2], nu[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE); 
                
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_REJECTED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages();
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: Pending -> Rejected, One Email should have been sent but number sent was: ' + sentEmail.size());
        results = sentEmail[0].getToAddresses();    
        System.assert(results.size() == 2, 'testAAStateTransitions: Pending -> Rejected, Email should have been sent to two addresses but was sent to: ' + results.size());
        
        //Testing for Rejected -> Rejected
        mockEmail.resetSentMessages();        
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_REJECTED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages();       
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Testing Rejected -> Rejected - Zero Email should have been sent but number sent was: ' + sentEmail.size());
        
        Test.stopTest();
     }
        
        
     static testMethod void testAAStateTransitionsPart2(){
        
        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Pittsburgh', 'Pirates', true);

        /* DEBUG OFF
        System.debug('testStateTransitions: test application is: ' + app);
        /* DEBUG */

        List<User> nu = ADM_ApplicationApprover.createTestUsers();
        // nu[0] is the first sample Application Approver
        // nu[1] and nu[2] are not used       
        
        ADM_Application_Approver__c aa = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[0], nu[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_QE);
        ADM_Application_Approver__c aa1 = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[1], nu[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV);             
        ADM_Application_Approver__c aa2 = ADM_ApplicationApprover.createTestApplicationApprover(app, nu[2], nu[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
            ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE);            

        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);

        Test.startTest();

        //Testing for Pending -> Need More Info 
        mockEmail.resetSentMessages();                    
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_NMI;
        Database.update(err);
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: Pending -> NMI, One Email should have been sent but number sent was: ' + 
            sentEmail.size() + ' sentEmail=' + sentEmail);
        List <String> results = sentEmail[0].getToAddresses();        
        System.assert(results.size() == 2, 'testAAStateTransitions: Pending -> NMI, Email should have been sent to two addresses but was sent to: ' + results.size());        
        
        //Testing for NMI -> NMI
        mockEmail.resetSentMessages();          
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_NMI;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages(); 
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Testing NMI -> NMI - Zero Email should have been sent but number sent was: ' + sentEmail.size());

        //Testing for Need More Info -> Withdrawn
        mockEmail.resetSentMessages();                  
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_WITHDRAWN;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages();
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: NMI -> Withdrawn, One Email should have been sent but number sent was: ' + sentEmail.size()+' sentEmail='+sentEmail);
        results = sentEmail[0].getToAddresses();        
        System.assert(results.size() == 2, 'testAAStateTransitions: NMI -> Withdrawn, Email should have been sent to two addresses but was sent to: ' + results.size());
        
        //Testing for Withdrawn -> Withdrawn
        mockEmail.resetSentMessages();
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_WITHDRAWN;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages(); 
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Testing Withdrawn -> Withdrawn - Zero Email should have been sent but number sent was: ' + sentEmail.size());
        
        //Testing for Withdrawn -> Approved
        mockEmail.resetSentMessages();
        
        // Changing third approver's Type to eReleases should result in email being sent to an additional To 
        aa2.Approval_Type__c = ADM_ApplicationApprover.TYPE_ERELEASES;
        Database.update(aa2);
        
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages();
        System.assert(sentEmail.size() == 1, 'testAAStateTransitions: Withdrawn -> NMI, One Email should have been sent but number sent was: ' + 
            sentEmail.size() +' sentEmail='+sentEmail);
        results = sentEmail[0].getToAddresses();            
        System.assert(results.size() == 3, 'testAAStateTransitions: Withdrawn -> NMI, Email should have been sent to three addresses but was sent to: ' + results.size());
        
        //Testing for Approved -> Released
        mockEmail.resetSentMessages();

        final String TEST_RELEASE_NAME = 'Test Release 123';
        final Datetime REL_DATE = Datetime.now();
                
        ADM_Release__c release1 = ADM_Release.createTestRelease(TEST_RELEASE_NAME,REL_DATE, null, 60);
        err.Released_In__c = release1.Id;
        
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_RELEASED;
        Database.update(err);
        sentEmail = mockEmail.getSentMessages();
        /* DEBUG OFF System.debug('testStateTransitions: Approved -> Released, sentEmail=' + sentEmail); /* DEBUG */             
        System.assert(sentEmail.size() == 0, 'testAAStateTransitions: Approved -> Released, No Emails should have been sent but number sent was:' + 
            sentEmail.size() + 'sentEmail=' + sentEmail);
            
        Test.stopTest();        
     }

    /**
     * Application with multple Approvers, validate Notify When Approved context.
     * Submit an ERR for an Application that has the Send_Emai_Notifications__c field 
     * set to true and there is at least three Application Approvers associated with 
     * this Application. One of these Approvers is ADM_ApplicationApprover.CONTEXT_NOTIFY.
     * Verify this user is only notified when ERR status becomes Approved.
     * testcaseID a1DB00000002tCY
     * @userStory W-1224650
     * @hierarchy GUS.eRelease Request.Notification Email
     * @priority Medium
     */
     
     static testMethod void testApplicationNotifyWhenApproved() {
     
        COM_EmailUtils.MockEmailService mockEmail = new COM_EmailUtils.MockEmailService();
        COM_EmailUtils.setEmailService((COM_EmailUtils.EmailService)mockEmail);
     
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', null, null);
        app = [select Enable_ERR_Notification_Emails__c from ADM_Application__c where id =: app.id];  
        app.Enable_ERR_Notification_Emails__c = true;
        update(app);
        
        List <ADM_Application_Approver__c> aaList = ADM_ApplicationApprover.createTestApplicationApprovers(app);
		// Set Approvers characteristics to those needed by this test
		aaList[0].Approval_Context__c = ADM_ApplicationApprover.CONTEXT_NOTIFY;
		update(aaList[0]);
 		aaList[1].Approval_Type__c = ADM_ApplicationApprover.TYPE_ERELEASES;
 		update(aaList[1]);
 		aaList[3].Approval_Type__c = ADM_ApplicationApprover.TYPE_ERELEASES;
 		update(aaList[3]);
        
        eRelease_Request__c err = ADM_eReleaseRequest.setupTestEReleaseRequest(work, app, null, null, null);
        
        Database.insert(err);
            
        List<Messaging.SingleEmailMessage> sentEmail = mockEmail.getSentMessages();
        /* DEBUG ON */ System.debug('testApplicationNotifyWhenApproved: sentEmail=' + sentEmail);

        System.assert(sentEmail.size() == 1, 'testApplicationNotifyWhenApproved: One Email should have been sent but number sent was: ' + sentEmail.size());
        List <String> results = sentEmail[0].getToAddresses();            
        System.assert(results.size() == 3, 'testApplicationNotifyWhenApproved: On ERR creation, Email should have been sent to three addresses but was sent to: ' + results.size());
        
        mockEmail.resetSentMessages();
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
        
        Database.update(err);
        System.assert(sentEmail.size() == 1, 'testApplicationNotifyWhenApproved: One Email should have been sent but number sent was: ' + sentEmail.size());
        results = sentEmail[0].getToAddresses();            
        System.assert(results.size() == 4, 'testApplicationNotifyWhenApproved: On ERR creation, Email should have been sent to four addresses but was sent to: ' + results.size());      
     } 

     static testMethod void testAssociatedToRedAccountReturnTrueForCaseWithAccountStageOpen(){
        ADM_Case__c testOrg62Case = ADM_Case.createTestCaseWithAccountStage('Open');
        ADM_Application__c app = ADM_Application.createTestApplication('Pittsburgh', 'Pirates', true);

        ADM_Work__c testWorkFromOrg62Case = ADM_Work.getById(testOrg62Case.work__c);  
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(testWorkFromOrg62Case, app, null, null, null);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(err);
        ADM_eReleaseRequest eReleaseRequest = new ADM_eReleaseRequest(ctrl);

        System.assertEquals(true,eReleaseRequest.getAssociatedToRedAccount(), 'Expected to return True for getAssociatedToRedAccount method');
     }

     static testMethod void testAssociatedToRedAccountReturnTrueForCaseWithAccountStageNotOpen(){
        ADM_Case__c testOrg62Case = ADM_Case.createTestCaseWithAccountStage('Resolved');
        ADM_Application__c app = ADM_Application.createTestApplication('Pittsburgh', 'Pirates', true);

        ADM_Work__c testWorkFromOrg62Case = ADM_Work.getById(testOrg62Case.work__c);  
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(testWorkFromOrg62Case, app, null, null, null);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(err);
        ADM_eReleaseRequest eReleaseRequest = new ADM_eReleaseRequest(ctrl);

        System.assertEquals(false,eReleaseRequest.getAssociatedToRedAccount(), 'Expected to return false for getAssociatedToRedAccount method');
     }

         
}