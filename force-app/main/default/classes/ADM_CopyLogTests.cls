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
private class ADM_CopyLogTests {
    static final String errorMessage = 'Test insert of a copy log with failures';
    static final String noErrorMessage = 'Test insert of a copy log without failures';

  /* 
      @testcaseID: a0B200000090DNYEA2      
      @hierarchy: GUS.BugforceToGus.Copy Logs page.Review copy logs      
      @userstory: a0A20000001092Z
      @expectedResults:  Correct recovery of the copy log when there is an error   
      @author Alexis Williams
    */ 

    static testMethod void insertCopyLogErrorTypeError() {
        ADM_Copy_Log__c cl = new ADM_Copy_Log__c();
        cl.Copied_From__c = Datetime.now().addHours(-1);
        cl.Copied_On__c = Datetime.now();
        cl.Failures__c = 1.0;
        cl.Text__c = errorMessage;
        cl.Title__c = 'error 1';
        cl.Type__c = 'Error';
        cl.Upserts__c = 1.0;
        insert cl;
        System.assertNotEquals(null, cl.Id);
    }

  /* 
      @testcaseID: a0B200000090DNZEA2      
      @hierarchy:  GUS.BugforceToGus.Copy Logs page.Review copy logs     
      @userstory: a0A20000001092Z
      @expectedResults:  Correct copy log type work   
      @author Alexis Williams
    */ 

    static testMethod void insertCopyLogWithoutErrorTypeWork() {
        ADM_Copy_Log__c cl = new ADM_Copy_Log__c();
        cl.Copied_From__c = Datetime.now().addHours(-1);
        cl.Copied_On__c = Datetime.now();
        cl.Failures__c = 0.0;
        cl.Text__c = errorMessage;
        cl.Title__c = 'error 0';
        cl.Type__c = 'Work';
        cl.Upserts__c = 1.0;
        insert cl;
        System.assertNotEquals(null, cl.Id);
    }

  /* 
      @testcaseID:  a0B200000090DNaEAM     
      @hierarchy: GUS.BugforceToGus.Copy Logs page.Review copy logs      
      @userstory: a0A20000001092Z
      @expectedResults:  Correct copy log type changelist   
      @author Alexis Williams
    */ 

    static testMethod void insertCopyLogTypeChangelist() {
        ADM_Copy_Log__c cl = new ADM_Copy_Log__c();
        cl.Copied_From__c = Datetime.now().addHours(-1);
        cl.Copied_On__c = Datetime.now();
        cl.Failures__c = 0.0;
        cl.Text__c = noErrorMessage;
        cl.Title__c = 'error 0';
        cl.Type__c = 'Changelist';
        cl.Upserts__c = 1.0;
        insert cl;
        System.assertNotEquals(null, cl.Id);
    }

  /* 
      @testcaseID:  a0B200000090DNbEAM     
      @hierarchy: GUS.BugforceToGus.Copy Logs page.Review copy logs      
      @userstory: a0A20000001092Z
      @expectedResults:  Correct recovery of the copy log when there is an exception   
      @author Alexis Williams
    */ 

    static testMethod void insertWithExceptionThrown() {
        ADM_Copy_Log__c cl = new ADM_Copy_Log__c();
        cl.Copied_From__c = Datetime.now().addHours(-1);
        cl.Copied_On__c = Datetime.now();
        cl.Failures__c = 0.0;
        cl.Text__c = errorMessage;
        cl.Title__c = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        cl.Type__c = 'Work';
        cl.Upserts__c = 1.0;
        try {
            insert cl;
        } catch(System.DmlException e) {
        	ADM_errorUtils eTools = new ADM_errorUtils();
            System.assertEquals(true, eTools.getErrorMessage(e).contains('data value too large'), '-' + eTools.getErrorMessage(e));
        }
    }
}