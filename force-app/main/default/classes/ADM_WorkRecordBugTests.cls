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
private class ADM_WorkRecordBugTests {
    public static String testFailure {
        get {
            if(testFailure == null) {
                testFailure = 'Test Failure';
            }
            return testFailure;
        }
        set;
    }
    
    public static String errorMessage {
        get {
            if(errorMessage == null) {
                errorMessage = 'Please enter a test when closing a bug';
            }
            return errorMessage;
        }
        set;
    }
    
    public static ADM_errorUtils errorUtils {
        get {
            if(errorUtils == null) {
                errorUtils = new ADM_errorUtils();
            }
            return errorUtils;
        }
        set;
    }
   
    /**
    *@testcaseID a0B20000008yHGiEAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/
    /**
    *@testcaseID a0B20000008yHGjEAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/
    /**
    *@testcaseID a0B20000008yHGkEAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/
    testMethod static void setP3BugToClosedWithChangelist(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P3');
        
        Test.startTest();
            work.Status__c = 'Closed';
            work.Number_of_Change_Lists__c = 200;
            insert work;
        Test.stopTest();
    }
    
    /**
    *@testcaseID a0B20000008xe3mEAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/
    /**
    *@testcaseID a0B20000008xe3rEAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/
    /**
    *@testcaseID a0B20000008xe41EAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/

    testMethod static void setP1BugToClosedWithChangelist(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');
        
        Test.startTest();
            work.Status__c = 'Closed';
            work.Number_of_Change_Lists__c = 200;
            try {
                insert work;
            } catch(System.DmlException e) {
                System.assertEquals(errorMessage, errorUtils.getErrorMessage(e));
            }
        Test.stopTest();
    }
    
     /**
    *@testcaseID a0B20000008xe3tEAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/   
     /**
    *@testcaseID a0B20000008xe43EAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/ 
     /**
    *@testcaseID a0B20000008xe4rEAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Bug is saved with no errors
*/ 
    testMethod static void setP3BugToClosedWithChangelistAndCases(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P3');
        
        Test.startTest();
            work.Status__c = 'Closed';
            work.Number_of_Change_Lists__c = 200;
           
            try {
                insert work;
            } catch(System.DmlException e) {
                System.assertEquals(errorMessage, errorUtils.getErrorMessage(e));
            }
        Test.stopTest();
    }
    
        /**
    *@testcaseID a0B20000008xe89EAA
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
    
        /**
    *@testcaseID a0B20000008xe8CEAQ
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
    
        /**
    *@testcaseID a0B20000008xe8FEAQ
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
    testMethod static void setP3TestFailureToClosedWithChangelist(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P3', testFailure);
        
        Test.startTest();
            work.Type__c = testFailure;
            work.Status__c = 'Closed';
            work.Priority__c = 'P3';
            work.Resolution__c = 'App Change';
            work.Number_of_Change_Lists__c = 200;
            insert work;
        Test.stopTest();
    }
    
        /**
    *@testcaseID a0B20000008xe8AEAQ
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
        /**
    *@testcaseID a0B20000008xe8AEAQ
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
        /**
    *@testcaseID a0B20000008xe8DEAQ
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
    testMethod static void setP1TestFailureToClosedWithChangelist(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1', testFailure);
        
        Test.startTest();
            work.Status__c = 'Closed';
            work.Number_of_Change_Lists__c = 200;
            work.Resolution__c = 'App Change';
            work.Type__c = testFailure;
            work.Priority__c = 'P1';
            try {
                insert work;
            } catch(System.DmlException e) {
                System.assertEquals(errorMessage, errorUtils.getErrorMessage(e));
            }
        Test.stopTest();
    }
    
        /**
    *@testcaseID a0B20000008yHFzEAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
        /**
    *@testcaseID a0B20000008yHG0EAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
        /**
    *@testcaseID a0B20000008yHG1EAM
    *@hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Edit and New page
    *@userstory a0790000000DGk6AAG
    *@expectedResults  Test Failure is saved with no errors
*/
    testMethod static void setP3TestFailureToClosedWithChangelistAndCases(){
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P3', testFailure);
        
        Test.startTest();
            work.Status__c = 'Closed';
            work.Number_of_Change_Lists__c = 200;
            work.Resolution__c = 'App Change';
            work.Type__c = testFailure;
            work.Priority__c = 'P3';
            try {
                insert work;
            } catch(System.DmlException e) {
                System.assertEquals(errorMessage, errorUtils.getErrorMessage(e));
            }
        Test.stopTest();
    }
}