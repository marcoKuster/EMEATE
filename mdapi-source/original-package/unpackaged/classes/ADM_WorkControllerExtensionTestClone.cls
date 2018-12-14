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


private class ADM_WorkControllerExtensionTestClone {

    /*
      @testcase: a1DB00000000gcg
      @hierarchy: GUS.ScrumforceToGUS.Work.Bug.Clone page
      @userstory: a07B0000000E4o7
      @expectedResults: The selected attributes from original bug or user story should not have been cloned along. Cloned bug or user story should have all attributes unselected, except "Required Testing" for user stories or "Regressed" for Test Failures
      @author Alexis Williams
    */
    static testMethod void verifyAttributesAreNullOnClone() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work.Attributes__c = 'Regressed';
        insert work;
        System.currentPageReference().getParameters().put('id', work.Id);
        System.currentPageReference().getParameters().put('clone', '1');
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());        
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c clone = ext.getWork();
        System.assertEquals(null, clone.Attributes__c);         
    }

        /*
      @testcase: a1DB00000000gcb
      @hierarchy: GUS.ScrumforceToGUS.Work.Bug.Clone page
      @userstory: a07B0000000E2zj
      @expectedResults: A bug's test failures should not clone from original. The cloned bug's test failures should equal zero
      @author Alexis Williams
    */
    static testMethod void verifyNumberOfTestFailuresAreNullOnClone() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work.of_Test_Failures__c = 20;
        insert work;
        System.currentPageReference().getParameters().put('id', work.Id);
        System.currentPageReference().getParameters().put('clone', '1');
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());        
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c clone = ext.getWork();
        System.assertEquals(null, clone.of_Test_Failures__c);         
    }
    
  
    
    /*
      @testcase: a1DB00000000jI7MAI
      @hierarchy: GUS.ScrumforceToGUS.Work.Bug.Clone page
      @userstory: a07B0000000DnIZIA0
      @expectedResults: When cloning the bug of type test failure, the type stays as test failure
      @author Alexis Williams
    */
    static testMethod void verifyStickyTypesWhenCloning() {      
        ADM_Work__c bug = ADM_Work.createTestBug();
        String typeOriginal = bug.Type__c;
        System.assertNotEquals('Bug List', bug.Type__c);        
        bug.Type__c = 'Bug List';
        update bug;
        
        ADM_Work__c work;
        
        System.currentPageReference().getParameters().put('clone', '1');  
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        work = ext.getWork();
        
        System.assertEquals('Bug List', work.Type__c);
        System.assertNotEquals(typeOriginal, work.Type__c);
    }
}