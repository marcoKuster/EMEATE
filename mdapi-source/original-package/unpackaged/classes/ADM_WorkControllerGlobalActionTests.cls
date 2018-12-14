@IsTest
private class ADM_WorkControllerGlobalActionTests {
    
    testMethod static void testWorkItemCreatedOnSaveAndViewForUserStory() {
         ADM_Work__c workToBeInserted = ADM_Work.setupTestWork('Bug');
         workToBeInserted.Details__c = 'Test Details';
         workToBeInserted.Subject__c = 'Test Subject';
        
         workToBeInserted.Priority__c = 'P1';
         ADM_WorkControllerGlobalAction storyGlobalAction = new ADM_StoryControllerGlobalAction();
         storyGlobalAction.work = workToBeInserted;
         storyGlobalAction.saveAndView();
         
         ADM_Work__c createdWork = ADM_Work.getById(workToBeInserted.id);
         
         System.assert('Test Subject' == createdWork.Subject__c, 'Subject is a required field for User Story');
         System.assert('Test Details' == createdWork.Details__c, 'Details__c (Description) expected');
         System.assert(createdWork.Product_Tag__c != null, 'Product Tag is required field for User Stroy');
    }
    
    testMethod static void testGetImpactOptions(){
        ADM_Impact__c i = new ADM_Impact__c(Name=String.valueOf(Math.random()));
        insert i;
        ADM_WorkControllerGlobalAction globalAction = new ADM_WorkControllerGlobalAction();
        System.assert(null != globalAction.getImpactOptions(), 'Expected Impact Options to be returned');
    }
    
    testMethod static void testGetFrequencyOptions(){
        ADM_Frequency__c f = new ADM_Frequency__c (Name=String.valueOf(Math.random()));
        insert f;
        ADM_WorkControllerGlobalAction globalAction = new ADM_WorkControllerGlobalAction();
        System.assert(null != globalAction.getFrequencyOptions(), 'Expected Frequency Options to be returned');
    }



}