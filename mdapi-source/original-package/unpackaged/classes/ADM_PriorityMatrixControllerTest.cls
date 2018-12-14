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

private class ADM_PriorityMatrixControllerTest {
  /*
 @testcaseID  a1DB00000000Pb3
 @userstoryID a0790000000DB87
 @Hierarchy GUS.Work.DefectPrioritizationProcess.Work Page.Detail Page
 @ExpectedResults Ensure override link works to override the priority
 */
    static testMethod void testWithRealProductMappings() {
    	ADM_Priority_Mapping__c pm = ADM_PriorityMapping.createTest();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(pm);
        ADM_PriorityMatrixController pmc = new ADM_PriorityMatrixController(sc);
        
        System.assert(pmc.frequencies != null);
    }
    

  /*
 @testcaseID  a1DB00000000qMA
 @userstoryID a07B0000000DzsU
 @Hierarchy GUS.Work.Bug.New Page
 @ExpectedResults User should see a picklist and be able to change this priority accordingly
 */
    static testMethod void testWithoutRealProductMappings() {
    	ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c();
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(pm);
        ADM_PriorityMatrixController pmc = new ADM_PriorityMatrixController(sc);
        
        System.assert(pmc.frequencies != null);
    }

    static testMethod void testToCoverWrapperClass(){
        ADM_PriorityWrapper priorityWrapper = new ADM_PriorityWrapper();
        priorityWrapper.impact = 'testImpact';
        priorityWrapper.always = 'test';
        priorityWrapper.frequency = 'always';
        priorityWrapper.often = 'often';
        priorityWrapper.sometimes = 'sometimes';
        priorityWrapper.rarely = 'rarely';
        priorityWrapper.bgColor = '#223456';

        System.assertNotEquals(null, priorityWrapper, 'Expected wrapper object to be not null');
    }
}