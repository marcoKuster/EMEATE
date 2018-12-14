public with sharing class ADM_WorkBatchTest {
    
    /**
     * Ensure that the Trigger logic can run with a batch of 50
     * @author jared.pearson
     */
    testMethod static void testBatch50Inserts() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(50, 'Bug');
        Test.startTest();
        insert works;
        Test.stopTest();
    }
    
    /**
     * Ensure that the Trigger logic can run with a batch of 100
     * @author jared.pearson
     */
    testMethod static void testBatch100Inserts() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(100, 'Bug');
        Test.startTest();
        insert works;
        Test.stopTest();
    }
    
    /**
     * Ensure that the Trigger logic can run with a batch of 200
     * @author jared.pearson
     */
    testMethod static void testBatch200Inserts() {
    	List<ADM_Work__c> works = ADM_Work.createListOfWork(200, 'Bug');
        Test.startTest();
    	insert works;
        Test.stopTest();
    }
    
    /**
     * Ensure that the Trigger logic can run with a batch of 500
     * @author jared.pearson
     */
    testMethod static void testBatch500Inserts() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(500, 'Bug');
        Test.startTest();
        insert works;
        Test.stopTest();
    }
}