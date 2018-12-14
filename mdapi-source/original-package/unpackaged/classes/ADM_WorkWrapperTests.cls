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
private class ADM_WorkWrapperTests {

    static testMethod void verifyEmptyWorkWrapper() {
        ADM_WorkWrapper ww = new ADM_WorkWrapper();
        System.assertEquals(false, ww.checked);
        System.assertEquals(0, ww.order);
        System.assertEquals(false, ww.stayInBucket);
    }

    static testMethod void verifyWorkWrapper() {
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestBug();
        Test.stopTest();
        ADM_WorkWrapper ww = new ADM_WorkWrapper(work);
        System.assertEquals(work, ww.work);
    }

    static testMethod void verifyWorkWrapperWithChecked() {
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestBug();
        Test.stopTest();
        ADM_WorkWrapper ww = new ADM_WorkWrapper(work, true);
        System.assertEquals(true, ww.checked);
        System.assertEquals(work, ww.work);
    }

    static testMethod void verifyWorkWrapperWithCheckedStayInBucket() {
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestBug();
        Test.stopTest();
        ADM_WorkWrapper ww = new ADM_WorkWrapper(work, true, true);
        System.assertEquals(true, ww.checked);
        System.assertEquals(true, ww.stayInBucket);
        System.assertEquals(work, ww.work);
    }
    
    /*
    @testcaseID  a1DB00000000qYl
    @userstory a07B0000000EMdc
    @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-868967
    @expected results The description should read from the description section for user stories, and from the subject for bugs and todos
    @Author: Alexis Williams
    */
  
    static testMethod void verifyWorkWrapperWithUserStory() {
    	ADM_Work__c work = ADM_Work.createTestWork('User Story');
    	work = ADM_Work.getOneBy('Id', work.Id);
    	ADM_WorkWrapper ww = new ADM_WorkWrapper(work);
    	System.assertEquals('', ww.getStoryLine());
    	work.Details__c = 'Lorem ipsum dolor sit amet';
    	update work;
    	ww = new ADM_WorkWrapper(work);
    	System.assertEquals(work.Details__c, ww.getStoryLine());
    }

}