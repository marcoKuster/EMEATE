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
private class ADM_WorkControllerExtensionTestBug {
    static ADM_Scrum_Team__c scrumteam {
        get {
            if(scrumteam == null) {
                scrumteam = ADM_ScrumTeam.createTestScrumTeam('Lorem ipsum');
            }
            return scrumteam;
        }
        set;
    }
    public static ADM_Work__c bug = ADM_Work.createTestBug();

    public static Apexpages.Standardcontroller stdCtrlr = new Apexpages.Standardcontroller(bug);
    public static ADM_WorkControllerExtension ctrlExt = new ADM_WorkControllerExtension(stdCtrlr);

    public static String nonRequiredInput = '';
    public static String requiredInput = 'requiredInput';

    static testMethod void getStatuses() {
        System.assert(ctrlExt.getStatuses() != null);
    }

    static testMethod void getMajorFunctionalAreas() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        String testMFA = 'Reporting';
        wrl.setMajorFunctionalArea(testMFA);
        System.assertEquals(testMFA, wrl.getMajorFunctionalArea());
        wrl.clearMajorFunctionalArea();
        wrl.clearProductAreaDependents();
        System.assert(wrl.getMajorFunctionalArea() == null);
    }

    

    

  /*      
    GUS Exception: ADM_Work : List has no rows for assignment to Sobject (bug W-742187)
    *@testcaseID a0B20000007nXAsEAM
    *@hierarchy GUS.BugforceToGUS.Bugs in GUS.W-742187 testtestesteteststest
    *@userstory a0A20000003V5FA
    *@expectedResults Outcome should be the page does not crash, and the query returns an empty record instead of a null. Here is the verbiage from the platform that is auto generated when this scenario plays out:
Data Not Available
The data you were trying to access could not be found. It may be due to another user deleting the data or a system error. If you know the data is not deleted but cannot access it, please look at our support page.

*/

    static testMethod void testLoadingWithDeletedRecord() {
        ADM_Work__c myWork = ADM_Work.createTestBug();
        ADM_Work__c testWork = new ADM_Work__c();
        System.currentPageReference().getParameters().put('Id', myWork.Id);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(testWork);

        Test.startTest();
        delete myWork;
        Test.stopTest();

        ADM_WorkControllerExtension extension = new ADM_WorkControllerExtension(controller);
        System.assertEquals(null, extension.getWork().Id);
    }

/*
    @testcaseID a1DB00000000Zgt
    @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-763843
    @userstory a07B0000000DV1n
    @expectedResults: After saving the work item, ensure the user is taken back to the last page from which the user came from, before editing the work page
    @author Alexis Williams
*/

     /*

      @testcase a1DB00000000Zgt
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-763843
      @userstory a0A20000003V5FA
      @expectedResults After saving the work item, ensure the user is taken back to the last page from which the user came from, before editing the work page
      @author Alexis Williams

    */
    static testMethod void verifyValueInUrlAfterSaveAndViewEditRecord() {
        Test.startTest();
        ADM_Work__c m_work = ADM_Work.createTestTodo();
        System.currentPageReference().getParameters().put('id', m_work.Id);
        System.currentPageReference().getParameters().put('retUrl', '/' + Userinfo.getUserId());
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c el = ext.getWork();
        Test.stopTest();
        el.Priority__c = 'P1';
        el.Assignee__c = Userinfo.getUserId();
        el.Scrum_Team__c = scrumteam.Id;
        el.Subject__c = 'Lorem ipsum';
        Pagereference pr = ext.saveAndView();
        
        System.assert(!ApexPages.hasMessages(), 'Expected the page to not have any error messages');
        System.assertNotEquals(null,pr);
        System.assertEquals('/' + Userinfo.getUserId(),pr.getUrl());
    }

    static testMethod void verifyRequiredInputs() {
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputType(), 'Type is required so the requiredInput css class should be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputStatus(), 'Status is required so the requiredInput css class should be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputProductTag(), 'Product Tag is required so the requiredInput css class should be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputProductArea(), 'Product Area is not required so the requiredInput css class should not be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputPriority(), 'Priority is required so the requiredInput css class should be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputMajorFuncArea(), 'Major Functional Area is not required so the requiredInput css class should not be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputMinorFuncArea(), 'Minor Functional Area is not required so the requiredInput css class should be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputSubject(), 'Subject is required so the requiredInput css class should be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputFoundInBuild(), 'Found in Build is required so the requiredInput css class should be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputCsContact(), 'CS Contact is not required so the requiredInput css class should not be returned.');
        System.assertEquals(requiredInput, ctrlExt.getRequiredInputScheduledBuild(), 'Scheduled Build is required so the requiredInput css class should be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputAssignee(), 'Assignee is not required so the requiredInput css class should not be returned.');
        System.assertEquals(nonRequiredInput, ctrlExt.getRequiredInputScrumteam(), 'Scrum Team is not required so the requiredInput css class should not be returned.');
    }

    static testMethod void getCoreValues(){
        //Get the record types
        Test.startTest();
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        User u = ADM_WorkUser.createTestUser();
        ADM_Work__c w = ADM_Work.createTestTodo();
        Map<Id,ADM_Scrum_Team__c> teamMap = new Map<Id,ADM_Scrum_Team__c>();
        Test.stopTest();
        w = ADM_Work.get('id', w.id, 'id', 'DESC');
        List<ADM_Build__c> builds = new List<ADM_Build__c>{ADM_Build.createTestBuild()};
        Map<Id, User> uMap = new Map<Id, User>(new List<User>{u});
        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(w, uMap, workRecordTypesById);
        String s = '';
        System.assertEquals('<a href="' + ADM_WorkUtils.GUS_URL + '/' + w.Id + '">' + ADM_WorkUtils.GUS_URL + '/' + w.Id + '</a>', coreValues.get('Link'));
        System.assertEquals(w.Type__c, coreValues.get('Type'));
        System.assertEquals(w.Subject__c, coreValues.get('Subject'));
        System.assertEquals(w.Priority__c, coreValues.get('Priority'));
        System.assertEquals(w.Status__c, coreValues.get('Status'));
        System.assertEquals(w.Assignee__c, coreValues.get('Assignee'));
    }

    /*
    testcase ID a0B20000008xER9EAM
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type bug and priority P4

	testcase ID a0B20000008xERAEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type bug list and priority P0

	testcase ID a0B20000008xERBEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Feature Request and priority P1

	testcase ID a0B20000008xERCEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Test Failure and priority P2

	testcase ID a0B20000008xERDEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type test case and priority P3

	testcase ID a0B20000008xEREEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Test Change and priority P4

	testcase ID a0B20000008xERFEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Test Tool and priority P4

	testcase ID a0B20000008xERGEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Help and priority P3

	testcase ID a0B20000008xERHEA2
	userstory ID a0790000000CvAxAAK
	Hierarchy GUS.BugforceToGUS.Bugs in GUS.W-666980
	Expected Results User is able to create a bug of type Integrate and priority P4
    */

    static testMethod void verifyPriorityOverUrl() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        Integer i = 0;
        Test.startTest();
        Set<String> TYPES_WHERE_PRIORITY_APPLIES = new Set<String>{'Bug List', 'Test Failure', 'Help'};
        for(String m_type : TYPES_WHERE_PRIORITY_APPLIES) {
        	String priority = 'P' + i;
        	System.currentPageReference().getParameters().put('Type__c', m_type);
        	System.currentPageReference().getParameters().put('Priority__c',priority);
	        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
	        Apexpages.Standardcontroller m_controller = new Apexpages.Standardcontroller(new ADM_Work__c());
	        ADM_WorkControllerExtension m_ext = new ADM_WorkControllerExtension(m_controller);
            System.assertEquals(priority, m_ext.getWork().Priority__c);
            i++;
        }
        Test.stopTest();
    }
    
	/*
	@testcaseID a1DB00000001Sot
	@userstory a07B0000000LbbcIAC
	@Expected results The URL passed from bug to child record looks similar this:
		https://gus.salesforce.com/apex/adm_workedituserstory?
		Minor_Func_Area__c=new+major+functional+area
		&Parent_ID__c=W-751773
		&Product_Tag__c=GUS+Admin%2FConfig+Change
		&RecordType=0129000000006gDAAQ
		&retUrl=%2Fapex%2Fadm_selectWorkRecordType
		&Scrum_Team__c=GUS
		
		&Subject__c=GUS%3A+Need+new+major+functional+area+for+Core+Performance+Team
		&Type__c=Bug
	@Hierarchy  GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	*/
    /*
    	@author 			james hatton
    	@expected results	verify product tags can be populated via the URL
    */
    static testMethod void verifyProductTagOverUrl() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        rule.Scrum_Team_Assignment__c = team.Id;
        insert rule;
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;
        
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = tag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        System.currentPageReference().getParameters().put('Product_Tag__c', tag.Name);
        System.currentPageReference().getParameters().put('Scrum_Team__c', team.Name);
        
		Apexpages.Standardcontroller m_controller = new Apexpages.Standardcontroller(new ADM_Work__c());
	    ADM_WorkControllerExtension m_ext = new ADM_WorkControllerExtension(m_controller);
        System.assertEquals(tag.Id, m_ext.getWork().Product_Tag__c);
    }

	/*
	@testcaseID a1DB00000001Soj
	@userstory a07B0000000LbbcIAC
	@Expected results 
	@Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	*/
    static testMethod void checkRequiredFieldsErrors() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        Apexpages.Standardcontroller m_controller = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension m_ext = new ADM_WorkControllerExtension(m_controller);

        Test.startTest();
        m_ext.saveAndNew();
        Test.stopTest();

        Set<String> errors = new Set<String> {'Priority','Subject','Product Tag','Found In Build'};
        String errorMessages = '';
        Integer errorCount = 0;
        
        ADM_Work__c work = m_ext.getWork();

        for(ApexPages.Message message : ApexPages.getMessages()) {
            errorMessages += message.getSummary();
        }

        for(String error : errors) {
            System.assertEquals(true,errorMessages.contains(error), 'error not found: ' + error + ' errorMessages: ' + errorMessages);
            errorCount++;
        }

        System.assertEquals(errors.size(),errorCount);
    }
    
    static testMethod void testCommentsMaxSizeIsValidated() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        Apexpages.Standardcontroller m_controller = new Apexpages.Standardcontroller(ADM_Work.setupTestWork('Bug'));
        ADM_WorkControllerExtension m_ext = new ADM_WorkControllerExtension(m_controller);
        ADM_Work__c work = m_ext.getWork();
        Test.startTest();
        //put over 31K characters in comments
        for(Integer i = 0; i < 31500; i++) {
        	work.Description__c = 'a' + work.Description__c;
        }
        m_ext.saveAndNew();
        Test.stopTest();

        String errorMessages = '';
        
        for(ApexPages.Message message : ApexPages.getMessages()) {
            errorMessages += message.getSummary();
        }

        System.assert(errorMessages.contains('A single comment cannot be longer than 31,000 characters. Consider using an attachment or linking to the source system.'));
        
    }
	
	/*
	@testcaseID: a1DB00000000t3I
      	@hierarchy: GUS.ScrumforceToGUS.Work Page.Bug.Edit Page
      	@userstory: a07B0000000Eih7IAC
      	@expectedResults: Assignees should not be populated on Bug if the user doesn't select both PA and MFA first.
      	@author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors(){
        ADM_Work__c work = new ADM_Work__c();
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
		String name = String.valueOf(Math.random());
        String assignee;
        String qa;
        String ue;
        
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
				
		rule.Product_Owner__c = Userinfo.getUserId();
		rule.Assignee_Assignment__c = Userinfo.getUserId();
		rule.QA_Assignment__c = Userinfo.getUserId();
		rule.UE_Engineer__c = Userinfo.getUserId();
        
        ext.getAutoAssignedWork();
        
        assignee = ext.getAssignee();
        qa = ext.getQa();
        ue = ext.getUe();
        
        System.assertEquals('', assignee);
        System.assertEquals('', qa);
        System.assertEquals('', ue);
        
        ext.setProductArea(name);
        ext.setMajorFunctionalArea(name);
        
        ext.getAutoAssignedWork();
        
        assignee = ext.getAssignee();
        qa = ext.getQa();
        ue = ext.getUe();
        
        System.assertEquals(ext.getAssignee(), assignee);
        System.assertEquals(ext.getAssignee(), qa);
        System.assertEquals(ext.getAssignee(), ue);
    }
}