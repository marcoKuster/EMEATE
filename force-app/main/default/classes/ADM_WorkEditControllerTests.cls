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
private class ADM_WorkEditControllerTests {
	
	private static ADM_WorkEditController getWorkEditController(ADM_Work__c work) {		
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkEditController eController = new ADM_WorkEditController(controller);
        return eController;
	}

/*
* @testcaseID a1DB00000000l6w
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.Bug Performance.New Page from URL
* @ExpecteResults The URL gets rendered correctly with no exceptions and all fields stated in the URL are filled in. Also the template shown in that of a Bug and the user gets the following error message: An error occurred getting the record type with the value provided over the URL, , resulting in the following error: List has no rows for assignment to SObject
* @Author: Alexis Williams
*/
    static testMethod void gotoEditDefaultPage() {        
        ADM_Work__c work = new ADM_Work__c();
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workeditbug'));                        
    }

/*
* @testcaseID a1DB00000000l72
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.User Story Performance.New Page
* @ExpecteResults The New user story page works normally when saving the user story
* @Author: Alexis Williams
*/
    static testMethod void gotoEditUserStoryPage() {        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workedituserstory'));                        
    }

/*
* @testcaseID a1DB00000000l6r
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.Bug Performance.New Page
* @ExpecteResults The New bug page works normally when saving the bug
* @Author: Alexis Williams
*/
    static testMethod void gotoEditBugPage() {        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workeditbug'));                        
    }

/*
* @testcaseID a1DB00000000l78
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.ToDo Performance.New Page
* @ExpecteResults The New todo page works normally when saving 
* @Author: Alexis Williams
*/
    static testMethod void gotoEditTodoPage() {        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_TODO);
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workedittodo'));                        
    }

/*
* @testcaseID a1DB00000000l79
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.Investigation Performance.New Page
* @ExpecteResults The assignees from assignment rule derived from PA/MFA/Sev selection are added instantenously
* @Author: Alexis Williams
*/
    static testMethod void gotoEditInvestigationPage() {        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workeditinvestigation'));                        
    }

/*
* @testcaseID a1DB00000000l77
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.Template Performance.New Page
* @ExpecteResults All fields are cloned from template to a bug layout
* @Author: Alexis Williams
*/
    static testMethod void gotoEditTemplatePage() {        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.TEMPLATE_RECORD_TYPE_NAME);
        ADM_WorkEditController controller = getWorkEditController(work);
        System.assertEquals(true, controller.gotoEditPage().getUrl().contains('adm_workedittemplate'));                        
    }

/*
* @testcaseID a1DB00000000l7F
* @userstoryID a07B0000000EAFe
* @Hierarchy GUS.BugforcetoGUS.Work.Bug Performance.New Page from URL
* @ExpecteResults The URL gets rendered correctly with no exceptions and all fields stated in the URL are filled in
* @Author: Alexis Williams
*/
    static testMethod void testProperlyEscapingURLValues() {
        String testSubject = 'Lorrem Ipsum -+=?.,|}{%%&**ab[c]|^tt_(9)-@#<>';
        String encoded = EncodingUtil.urlEncode(testSubject, 'UTF-8');
        System.currentPageReference().getParameters().put('Subject__c', testSubject);        
        System.currentPageReference().getParameters().put('Description__c', testSubject);        
        System.currentPageReference().getParameters().put('Status__c', testSubject);        
        System.currentPageReference().getParameters().put('Type__c', testSubject);        
        System.currentPageReference().getParameters().put('Minor_Func_Area__c', testSubject);        
        System.currentPageReference().getParameters().put('Priority__c', testSubject);        
        System.currentPageReference().getParameters().put('Email_Subscription_ID__c', testSubject);        
        System.currentPageReference().getParameters().put('Related_URL__c', testSubject);        
        System.currentPageReference().getParameters().put('ftest__c', testSubject);        
        System.currentPageReference().getParameters().put('Subscribe_to_Work__c', '1');       
        System.currentPageReference().getParameters().put('Priority_Rank__c', testSubject); 
        System.currentPageReference().getParameters().put('Sprint__c', testSubject); 
        System.currentPageReference().getParameters().put('Scrum_Team__c', testSubject); 
        System.currentPageReference().getParameters().put('Email_On_Save__c', '1');
        System.currentPageReference().getParameters().put('Customer__c', testSubject);
        System.currentPageReference().getParameters().put('Parent_ID__c', testSubject);
        System.currentPageReference().getParameters().put('Scheduled_Build__c', testSubject);
        System.currentPageReference().getParameters().put('Found_In_Build__c', testSubject);
        System.currentPageReference().getParameters().put('Priority_Rank__c', testSubject);
        
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.TEMPLATE_RECORD_TYPE_NAME);
        ADM_WorkEditController controller = getWorkEditController(work);
        
        System.assertEquals(encoded,controller.params.get('Subject__c'));
        System.assertEquals(encoded,controller.params.get('Description__c'));
        System.assertEquals(encoded,controller.params.get('Status__c'));
        System.assertEquals(encoded,controller.params.get('Type__c'));
        System.assertEquals(encoded,controller.params.get('Minor_Func_Area__c'));
        System.assertEquals(encoded,controller.params.get('Priority__c'));
        System.assertEquals(encoded,controller.params.get('Email_Subscription_ID__c'));
        System.assertEquals(encoded,controller.params.get('Related_URL__c'));
        System.assertEquals(encoded,controller.params.get('ftest__c'));
        System.assertEquals('1',controller.params.get('Subscribe_to_Work__c'));
        System.assertEquals(encoded,controller.params.get('Priority_Rank__c'));
        System.assertEquals(encoded,controller.params.get('Sprint__c'));
        System.assertEquals(encoded,controller.params.get('Scrum_Team__c'));
        System.assertEquals(encoded,controller.params.get('Scrum_Team__c'));
        System.assertEquals('1',controller.params.get('Email_On_Save__c'));
        System.assertEquals(encoded,controller.params.get('Customer__c'));
        System.assertEquals(encoded,controller.params.get('Parent_ID__c'));
        System.assertEquals(encoded,controller.params.get('Scheduled_Build__c'));
        System.assertEquals(encoded,controller.params.get('Found_In_Build__c'));
        System.assertEquals(encoded,controller.params.get('Priority_Rank__c'));
    }
}