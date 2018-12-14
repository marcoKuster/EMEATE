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
private class ADM_InvestigationProcessTests {
    public static String valueOf(List<String> els) {
      String returnEl = '';
      if(!els.isEmpty()) {
        for(String el : els) {
          returnEl += ' ' + el.toLowerCase();
        }
      }
      System.debug(returnEl);
      return returnEl;
    }
    
    public static String getApexErrorMessages() {
        String errorMessages = '';
        for(ApexPages.Message message : ApexPages.getMessages()) {
            errorMessages += ' ' + message.getSummary();
        }
        return errorMessages;
    }

    /*
      @testcaseID: a0B20000008yF0tEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyCEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyDEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors(){
        ADM_Work__c work = new ADM_Work__c();
    
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        
    //invoke the auto assigned work function, which will populate the 
    //errorMessages property
        //should get 0 errors here because product tag and severity equal null
        work = ext.getWork();
        work.Product_Tag__c = null;
        work.Severity_Level__c = null;
        ext.getAutoAssignedWork();
        String errors = getApexErrorMessages();
        System.assertEquals(false, errors.contains('product tag'), 'Not expecting errors to contain that product tag is required');
        System.assertEquals(false, errors.contains('severity level'), 'Not expecting errors to contain that severity level is required');
    }

    /*
      @testcaseID: a0B20000008yF0tEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyCEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyDEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors2(){
        ADM_Work__c work = new ADM_Work__c();
        
        //create the product tag
        ADM_Product_Tag__c productTag = createProductTagWithAssigmentRule();

        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        //set the product tag and invoke the assigned work.
        //should get 1 error here since severity is null
        work = ext.getWork();
        work.Product_Tag__c = productTag.Id;
        work.Severity_Level__c = null;
        ext.getAutoAssignedWork();
        String errors = getApexErrorMessages();
        System.assertEquals(false, errors.contains('product tag'), 'Not expecting errors to contain that product tag is required');
        System.assertEquals(true, errors.contains('severity level'), 'Expecting errors to contain that severity level is required');
    }
    
    
    /*
      @testcaseID: a0B20000008yF0tEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyCEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyDEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors3(){
        ADM_Work__c work = new ADM_Work__c();
        
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        
        //set the severity and invoke the assigned work.
        //should get 1 error here since product tag is null
        work = ext.getWork();
        work.Product_Tag__c = null;
        work.Severity_Level__c = '1';
        ext.getAutoAssignedWork();
        String errors = getApexErrorMessages();
        System.assertEquals(true, errors.contains('product tag'), 'Expecting errors to contain that product tag is required');
        System.assertEquals(false, errors.contains('severity level'), 'Not expecting errors to contain that severity level is required');
    }
    
    /*
      @testcaseID: a0B20000008yF0tEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyCEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000008yEyDEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Save and New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Ensure that the ajax loader loads the correct assignees from a combination of assignment rules and severity
      @author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors4(){
        ADM_Work__c work = new ADM_Work__c();
        
        //create the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        
        //create the assignment rule
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        insert tagAssignment;

        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        //set the product tag and severity and invoke the assigned work
        //should get 0 errors here since both are set
        work = ext.getWork();
        work.Product_Tag__c = productTag.Id;
        work.Severity_Level__c = '1';
        ext.getAutoAssignedWork();
        String errors = getApexErrorMessages();
        System.assertEquals(false, errors.contains('product tag'), 'Not expecting errors to contain that product tag is required');
        System.assertEquals(false, errors.contains('severity level'), 'Not expecting errors to contain that severity level is required');
    }
    
    /*
      @testcaseID: a0B20000008dOhOEAU
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: MFA, severity, PA, subject, scrum team, assignee and steps to reproduce are validated and rendered when saving a new investigation process
      @author Alexis Williams
    */

    static testMethod void testRequiredFields(){
        ADM_Work__c work = new ADM_Work__c();
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        try {
            ext.saveAndNew();
        } catch(System.DmlException e) {
            ADM_errorUtils errorUtils = new ADM_errorUtils();
            String error = errorUtils.getErrorMessage(e);
            System.assertEquals(true,error.contains('Major Functional Area'));
            System.assertEquals(true,error.contains('Severity Level'));
            System.assertEquals(true,error.contains('Product Area'));
            System.assertEquals(true,error.contains('Subject'));
            System.assertEquals(true,error.contains('Scrum Team'));
            System.assertEquals(true,error.contains('Assigned To'));
            System.assertEquals(true,error.contains('Details and Steps to Reproduce'));
        }
    }

      /*
      @testcaseID: a0B20000007miixEAA
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Subject: A <type> exception request has been filed for Investigation:<subject> Sev <sev level>
            Body:
            <Requestor> has requested the following exception: <type> to Investigation <subject> Sev <severity level> giving the following reason:
            <why - should come from the text field>
            <Assignee> please make your decision and update the record as appropriate.

            Exception Request <link>
            Investigation <link>
    @author Alexis Williams
    */
        /*
      @testcaseID: a0B20000007m9dAEAQ
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Email has the following fields:
        Email Subject: (Escalated to Senior Mgt) Investigation W-12345 - Sev x - CustNameSubString : Subject
        Email Body:
        Severity:
        Status:
        CS Contact:
        Assigned To:
        Scrum Team:                                                                                                                                                                                                                                                                                                                   Steps to Reproduce:
        Comments:
    @author Alexis Williams
    */


    static testMethod void testGetCoreValuesOnInsert(){
        //Get the record types
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        User u = ADM_WorkUser.createTestUser();
        ADM_Work__c w = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        w = ADM_Work.getOneBy('id', w.id);
        
        Map<Id,ADM_Scrum_Team__c> teamMap = new Map<Id,ADM_Scrum_Team__c>();

        w.Assignee__c = u.id;
        w.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
        Map<Id, User> uMap = new Map<Id, User>(new List<User>{u});
        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(true, w, uMap, workRecordTypesById);
        System.assertEquals(w.Subject__c, coreValues.get('Subject'));
        System.assertEquals(w.Product_Tag__r.Name, coreValues.get('Product Tag'));
        System.assertEquals(w.Priority__c, coreValues.get('Priority'));
        System.assertEquals(w.Status__c, coreValues.get('Status'));
        System.assertEquals(false,coreValues.containsKey('Help Status'));
        System.assertEquals(true,coreValues.containsKey('Details and Steps to Reproduce'));
        System.assertEquals(false,coreValues.containsKey('Scheduled Build'));
        System.assertEquals(true,coreValues.containsKey('CS Contact'));
        System.assertEquals(true,coreValues.containsKey('Severity Level'));
    }

     /*
      @testcaseID: a0B20000007mBfjEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: GUS emails assignees, subscribers and CS contact when there is a change to any field on the investigation process
      @author Alexis Williams
    */
         /*
      @testcaseID: a0B20000007mBmmEAE
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Email has the following fields:
    Email Subject: Investigation W-12345 - Sev x - CustNameSubString : Subject
    Email Body:
    Severity:
    Status:
    CS Contact:
    Assigned To:
    Scrum Team:
    Steps to Reproduce:
    Comments:
      @author Alexis Williams
    */

    static testMethod void testGetCoreValuesOnUpdate(){
        //Get the record types
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        User u = ADM_WorkUser.createTestUser();
        ADM_Work__c w = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        w = ADM_Work.getOneBy('id', w.id);
        Map<Id,ADM_Scrum_Team__c> teamMap = new Map<Id,ADM_Scrum_Team__c>();

        w.Assignee__c = u.id;
        w.Details_and_Steps_to_Reproduce__c = 'Details and Steps to Reproduce';
        Map<Id, User> uMap = new Map<Id, User>(new List<User>{u});
        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(false, w, uMap, workRecordTypesById);
        System.assertEquals(w.Subject__c, coreValues.get('Subject'));
        System.assertEquals(w.Product_Tag__r.Name, coreValues.get('Product Tag'));
        System.assertEquals(w.Priority__c, coreValues.get('Priority'));
        System.assertEquals(w.Status__c, coreValues.get('Status'));
        System.assertEquals(false,coreValues.containsKey('Help Status'));
        System.assertEquals(false,coreValues.containsKey('Details and Steps to Reproduce'));
        System.assertEquals(false,coreValues.containsKey('Scheduled Build'));
        System.assertEquals(true,coreValues.containsKey('CS Contact'));
        System.assertEquals(true,coreValues.containsKey('Severity Level'));
    }
/*
    @testcaseID a0B20000007m9dUEAQ
    @hierarchy :GUS.ScrumforceToGUS.Investigation Process.Check-In Code
    @userstory a0A20000006UsAZ
    @expectedResults: User is not allowed to check in code against an investigation page
    @author Alexis Williams
*/
/*
    @testcaseID a0B20000007m9f8EAA
    @hierarchy :GUS.ScrumforceToGUS.Investigation Process.Check-In Code
    @userstory a0A20000006UsAZ
    @expectedResults: User is not allowed to update/upsert (API data loader or mass update) the perforce status
    @author Alexis Williams
*/
    static testMethod void investigationUpdateP4Status() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        ext.doNothing();
        System.assertEquals(ext.getUser().Id, Userinfo.getUserId());

        work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
        Pagereference pr = ext.saveAndNew();
        System.assertEquals(true,Apexpages.hasMessages());
    }

/*
    @testcaseID a0B20000007m9dKEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Detail Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: User is not allowed to change investigation page to another record type
    @author Alexis Williams
*/
    static testMethod void changeInvestigationToUserStory() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        work = ext.getWork();
        work.Priority__c = 'P0';
        work.Priority_Override_Explanation__c = 'testing';
        work.Found_In_Build_Copy__c = ADM_Build.createTestBuild().Name;
        
        ext.saveAndView();
        for(Apexpages.Message message : ApexPages.getMessages()) {
            System.assertEquals(true, message.getDetail().contains('This type of record type conversion is not supported'), 'Expected an error about the record type conversion. Actual: ' + message.getDetail());
        }
    }

/*
    @testcaseID a0B20000007mBfkEAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: GUS records a comment when there is a change to any field on the investigation process
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9aJEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: A comment is saved and an email is sent to all that the executive involved box is on.  Users are emailed and comment is added when this field changes.
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9aKEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: A comment is saved and an email is sent to all that the red account box is on. Users are emailed and comment is added when this field changes.
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9aLEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: A comment is saved and an email is sent to all that the Critical CRM Feature or Org Inaccessible box is on
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9aMEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: New, Renewal, New and Renewal are the picklist selections. Users are emailed and comment is added when this field changes.
    @author Alexis Williams
*/
    static testMethod void updateCheckComments() {
        User u = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();

        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        work.Assignee__c = u.Id;
        work.QA_Engineer__c = u.Id;
        work.Product_Owner__c = u.Id;
        work.CS_Contact__c = u.Id;
        work.Scrum_Team__c = team.Id;
        work.Severity_Level__c = '4';
        work.Customer__c = 'ACME Inc.';
        work.Estimated_Financial_Impact__c = 200;
        work.Subject__c = work.Customer__c;
        work.Executive_Involved__c = true;
        work.Red_Account__c = true;
        work.Critical_CRM_Feature__c = true;
        work.Deal_at_Risk__c = 'New';
        work.Request_RD_Mgr_Review__c = true;
        work.Senior_Management_POC__c = u.Id;
        work.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';

        Test.startTest();
        ext.saveAndView();
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        System.assertEquals(null,updated.Priority__c);
        System.assertEquals(u.Id,work.Assignee__c);
        System.assertEquals(true,comment.Body__c.contains('Assignee'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('QA Engineer'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Product Owner'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Support Contact'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Severity Level'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Customer, ' + work.Customer__c + ', has been added'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Estimated Financial Impact'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Subject'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Executive Involved'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Red Account'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Critical CRM Feature'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Deal at Risk'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Request R&amp;D Mgr Review changed from false to true'),'->' + comment.Body__c);
        System.assertEquals(true,comment.Body__c.contains('Senior Management POC'),'->' + comment.Body__c);
    }


/*
    @testcaseID a0B20000007mBmlEAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Comment is added and email sent that the status is sent. Resolved, Resolved On, Resolved By, Closed, Closed On and Closed By fields are populated
    @author Alexis Williams
*/
    static void testClosedField(ADM_Work__c updated, ADM_Comment__c comment, String status) {
        System.assertEquals(1,Math.round(updated.Resolved__c));
        System.assertEquals(Userinfo.getUserName(),updated.Resolved_By__c);
        System.assertEquals(true,System.now().isSameDay(updated.Resolved_On__c));
        System.assertEquals(1,Math.round(updated.Closed__c));
        System.assertEquals(Userinfo.getUserName(),updated.Closed_By__c);
        System.assertEquals(true,System.now().isSameDay(updated.Closed_On__c));
        System.assertEquals(true,comment.Body__c.contains('Status'),'->' + comment.Body__c);
    }

/*
    @testcaseID a0B20000007mBmmEAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Comment is added and email sent that the status is sent. Resolved, Resolved On, Resolved By, Closed, Closed On and Closed By fields are populated
    @author Alexis Williams
*/
    static testMethod void changeStatusToRejected() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        System.currentPageReference().getParameters().put('Status__c', 'Rejected');
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        Test.startTest();
        ext.saveAndView();
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated, comment, work.Status__c);
    }





/*
    @testcaseID a0B20000007mBn0EAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Comment is added and email sent that the status is sent. Resolved, Resolved On, Resolved By, Closed On and Closed By fields are populated
    @author Alexis Williams
*/
    static testMethod void changeStatusToClosedNoFixWorkingAsDesigned() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - No Fix - Working as Designed';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }

/*
    @testcaseID a0B20000007mBn1EAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Comment is added and email sent that the status is sent. Resolved, Resolved On, Resolved By, Closed, Closed On and Closed By fields are populated
    @author Alexis Williams
*/
    static testMethod void changeStatusToClosedNoFixFeatureRequest() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - No Fix - Feature Request';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }

/*
    @testcaseID a0B20000007mBn2EAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Comment is added and email sent that the status is sent. Resolved, Resolved On, Resolved By, Closed, Closed On and Closed By fields are populated
    @author Alexis Williams
*/
    static testMethod void changeStatusToClosedNoFixWillNotFix() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - No Fix - Will Not Fix';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }

       /*
      @testcaseID: a1DB00000000gfB
      @hierarchy:GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
      @userstory: a0790000000DApf
      @expectedResults: The investigation is closed and the closed flag =1, closed by receives a user ID and closed date receives a date
      @author Alexis Williams
    */
    static testMethod void changeStatusToClosedLAPRequestApproved() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - LAP Request Approved';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }
       /*
      @testcaseID: a1DB00000000gfG
      @hierarchy:GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
      @userstory: a0790000000DApf
      @expectedResults: The investigation is closed and the closed flag =1, closed by receives a user ID and closed date receives a date
      @author Alexis Williams
    */
    static testMethod void changeStatusToClosedLAPRequestDenied() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - LAP Request Denied';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }
       /*
      @testcaseID: a1DB00000000gfH
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.Edit Investigation page
      @userstory: a0790000000DApf
      @expectedResults: The investigation is closed and the closed flag =1, closed by receives a user ID and closed date receives a date
      @author Alexis Williams
    */
    static testMethod void changeStatusToClosedResolvedWithoutCodeChange() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        work.Status__c = 'Closed - Resolved Without Code Change';

        Test.startTest();
        update work;
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];

        testClosedField(updated,comment,work.Status__c);
    }
    /*
    @testcaseID a0B20000007m7rsEAA
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: First section of the investigation new page shows  product area, major func area, severity - all mandatory fields, whereas Customer, Number of Users Impacted, Estimated Financial Impact, product child, #of cases, Status, SFDC Exec Involvement , Red Account, Critical CRM Feature or Org Inaccessible, Deal at risk are optional fields
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m98AEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Second section of the investigation new page shows subject - mandatory field
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9C3EAI
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Third section of the investigation new page shows scrum team, CS Contact - mandatory fields and Product Owner, Assign to, Senior Management POC, Request R&D Mgr Review and QA Engineer are all optional fields
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9CrEAI
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Fourth section of the investigation new page shows To field, Email on Save and subscribe to work, all optional fields
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9CsEAI
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Fifth section of the investigation new page shows Steps to Reproduce and Comments, optional fields
    @author Alexis Williams
*/
    static testMethod void checkRequiredFields() {
        ADM_Work__c work = new ADM_Work__c();
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        /*System.assertEquals('requiredInput',ext.getRequiredInputAssignee()); 
        System.assertEquals('requiredInput',ext.getRequiredInputCsContact()); 
        System.assertEquals('requiredInput',ext.getRequiredInputMajorFuncArea());
        System.assertEquals('requiredInput',ext.getRequiredInputProductArea());
        System.assertEquals('requiredInput',ext.getRequiredInputScrumteam());
        System.assertEquals('requiredInput',ext.getRequiredInputSubject());
        System.assertEquals('',ext.getRequiredInputFoundInBuild());
        System.assertEquals('',ext.getRequiredInputMinorFuncArea());
        System.assertEquals('',ext.getRequiredInputScheduledBuild());
        System.assertEquals('',ext.getRequiredInputStatus());
        System.assertEquals('',ext.getRequiredInputType());
        System.assertEquals('',ext.getRequiredInputPriority());*/


        Test.startTest();
        ext.saveAndNew();
        Test.stopTest();

        Set<String> errors = new Set<String> {'Product Tag'};
        String errorMessages = getApexErrorMessages();
        Integer errorCount = 0;
        
        work = ext.getWork();
        if(work.Product_Area__c != null && work.Product_Area__c.length() > 0) {
          errors.remove('Product Area');
        }
        
        for(String error : errors) {
            System.assertEquals(true,errorMessages.contains(error), 'error not found: ' + error + ' errorMessages: ' + errorMessages);
            errorCount++;
        }

        System.assertEquals(errors.size(),errorCount); 
    }

/*
    @testcaseID a0B20000007m9KMEAY
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: "Status picklist for investigation shows:
    New
    Acknowledged
    Investigating
    More Info Reqd from Support
    Rejected
    Eng Internal
    Closed - Duplicate
    Closed - Known Bug Exists
    Closed - New Bug Logged
    Closed - LAP Request Approved
    Closed - LAP Request Denied
    Closed - Resolved Without Code Change
    Closed - No Fix - Working as Designed
    Closed - No Fix - Feature Request
    Closed - No Fix - Will Not Fix
    Closed - Eng Internal
    @author Alexis Williams
*/
    static testMethod void checkInvestigationStatusFields() {
        ADM_Work__c work = new ADM_Work__c();
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        Set<String> STATUS_VALUES_INVESTIGATION = new Set<String>{'New','Acknowledged','Investigating','More Info Reqd from Support', 'Rejected', 'Closed - Duplicate', 'Closed - Known Bug Exists', 'Closed - New Bug Logged','Closed - LAP Request Approved','Closed - LAP Request Denied', 'Closed - Resolved Without Code Change', 'Closed - No Fix - Working as Designed','Closed - No Fix - Feature Request','Closed - No Fix - Will Not Fix'};

        ADM_WorkStatus.createOrUpdateAllWorkStatusRecords();
        List<Selectoption> statuses = ext.getStatuses();
        for(Selectoption status : statuses) {
            if(STATUS_VALUES_INVESTIGATION.contains(status.getLabel())) {
                STATUS_VALUES_INVESTIGATION.remove(status.getLabel());
            }
        }

        System.assertEquals(0, STATUS_VALUES_INVESTIGATION.size());

        STATUS_VALUES_INVESTIGATION = new Set<String>{'New','Acknowledged','Investigating','More Info Reqd from Support', 'Rejected', 'Closed - Duplicate', 'Closed - Known Bug Exists', 'Closed - New Bug Logged','Closed - LAP Request Approved','Closed - LAP Request Denied', 'Closed - Resolved Without Code Change', 'Closed - No Fix - Working as Designed','Closed - No Fix - Feature Request','Closed - No Fix - Will Not Fix'};
        Map<String, Schema.SObjectField> fieldsMap = Schema.Sobjecttype.ADM_Work__c.fields.getMap();
        Schema.Sobjectfield statusField = fieldsMap.get('Status__c');
        for(Schema.Picklistentry status : statusField.getDescribe().getPicklistValues()) {
            if(STATUS_VALUES_INVESTIGATION.contains(status.getLabel())) {
                STATUS_VALUES_INVESTIGATION.remove(status.getLabel());
            }
        }

        System.assertEquals(0, STATUS_VALUES_INVESTIGATION.size());

    }

/*
    @testcaseID a0B20000007m9VsEAI
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Adding comments to Comments section should have the same functionality as that of the bug and user story layout. Adding comments generate emails to assignees and subscribers alike
    @author Alexis Williams
*/
    static testMethod void addCommentToInvestigation() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        work.Description__c = 'new comment!';

        Test.startTest();
        ext.saveAndView();
        Test.stopTest();

        ADM_Work__c updated = ADM_Work.getAll(work.Id)[0];
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];
    }

    static testMethod void verifyRenderedFields() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        System.assertEquals(false,ext.renderFrequencyAndImpact);
        System.assertEquals(false,ext.renderType);
    }

/*
    @testcaseID a0B20000007mBjbEAE
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: When creating a new investigation work page, the CS contact gets automatically populated with the creator's name and gets auto-subscribed
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9aMEAQ
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: All assignees, subscribers and CS contact get emailed when a new investigation process is created
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007m9WNEAY
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: The investigation process should save and a new investigation process page should appear
    @author Alexis Williams
*/
    static testMethod void verifyCsContactSubscribed() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Work__c work = ext.getWork();

        work.Assignee__c = Userinfo.getUserId();
        work.QA_Engineer__c = Userinfo.getUserId();
        work.Product_Owner__c = Userinfo.getUserId();
        work.CS_Contact__c = Userinfo.getUserId();
        work.Scrum_Team__c = team.Id;
        work.Severity_Level__c = '4';
        work.Customer__c = 'ACME Inc.';
        work.Estimated_Financial_Impact__c = 200;
        work.Subject__c = work.Customer__c;
        work.Executive_Involved__c = true;
        work.Red_Account__c = true;
        work.Critical_CRM_Feature__c = true;
        work.Deal_at_Risk__c = 'New';
        work.Request_RD_Mgr_Review__c = true;
        work.Senior_Management_POC__c = Userinfo.getUserId();
        work.Product_Area__c = 'GUS';
        work.Major_Func_Area__c = 'Other';
        work.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
        System.assertEquals(true, work.Subscribe_to_Work__c);
        Test.startTest();
        ext.saveAndNew();
        Test.stopTest();

        ADM_Work_Subscriber__c subscriber = ADM_Subscriber.get(Userinfo.getUserId(), work.Id);
        System.assertNotEquals(null, subscriber);
    }

       /*
      @testcaseID: a1DB00000000bQP
      @hierarchy: GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults: Email on Save stays ON without the need to check it. User who creates the investigation also gets subscribers. Therefore, all assignees, subscribers and users on the To field get emailed
      @author Alexis Williams
    */
    static testMethod void verifyEmailOnSaveByDefault() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Work__c work = ext.getWork();

        System.assertEquals(true, work.Email_On_Save__c);
    }
       /*
      @testcaseID: a1DB00000000gfL
      @hierarchy:GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory: a0A20000006UsAZ
      @expectedResults:  Support Contact is notified when creating a new investigation
      @author Alexis Williams
    */
    static testMethod void verifySupportContactNotified() {
      System.assertEquals(true,ADM_Work.USERS_WHO_RECEIVE_NOTIFICATION_FOR_WORK.contains('CS_Contact__c'));
    }

/*
    @testcaseID a0B20000007mBUKEA2
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Investigation work page allows user to add a child id of any record type and the relationship is saved
    @author Alexis Williams
*/

/*
    @testcaseID a0B20000007mBULEA2
    @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
    @userstory a0A20000006UsAZ
    @expectedResults: Investigation work page allows user to add a child of any record type and the relationship is saved
    @author Alexis Williams
*/

    static testMethod void createChildWithBug() {
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);

        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_WorkTreeController tree = new ADM_WorkTreeController(controller);

        tree.setRelatedChildWorkCreateFlag();
        //this variable is not visible. cannot create the test outside of this class as a result.
        //tree.newChildWork.Child_Work__c = bug.Id;

        Test.startTest();
        tree.createNewChildWork();
        Test.stopTest();

        //System.assertEquals(work.Id, tree.getNewChildWork().Parent_Work__c);
    }

    private static ADM_Product_Tag__c createProductTagWithAssigmentRule() {
      
        //create the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        
        //create the assignment rule
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        insert tagAssignment;
      
      return productTag;
    }
   
}