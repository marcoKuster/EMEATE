@isTest
class ADM_WorkSLAFeedItemOrComment_Test {

    /** Insert sample data to be used by other test methods */
    @testSetup static void setup() {
        ADM_WorkSLATestData.setupTestData();
    }

    /**
     * Test that investigation due date reset after add new feed comment. Cover ADM_FeedCommentTrigger
     */
    @isTest static void ftest_FeedCommentInvokeDueDateReset() {
      
        // insert some data
        ADM_Work__c investigation = generateTestInvestigation();
        
        FeedItem post = new FeedItem();
        
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            post = generateTestFeedItem(investigation.Id, 'Made a lot of progress');
        }
        
        Test.startTest();
        
        // Phase I. Change Due Date Time back to a time, so that our reset code not depend on the time we run the code.
        DateTime fixedDueDateTime = Datetime.newInstance(2015, 4, 27, 16, 55, 0);
        investigation.Due_Date__c = fixedDueDateTime.date();
        update investigation;        
        
        // Phase II. Get current SLA due date.        
        DateTime oldDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;
        
        // Phase III. Make a feed comment.
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            FeedComment commment = generateTestFeedComment(post.Id, 'Still investigating');
        }
        
        DateTime newDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;        
        
        if(oldDueTime != null && newDueTime != null) {
          System.assert(oldDueTime.getTime() < newDueTime.getTime());  
        }
        
        
        Test.stopTest();
    }
    
    @isTest static void ftest_FeedCommentDontInvokeDueDateReset() {
        // insert some data
        ADM_Work__c investigation = generateTestInvestigation();
        
        FeedItem post = new FeedItem();
        
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            post = generateTestFeedItem(investigation.Id, 'Made a lot of progress');
        }
        
        Test.startTest();
        
        // Phase I. Change Due Date Time back to a time, so that our reset code not depend on the time we run the code.
        DateTime fixedDueDateTime = Datetime.newInstance(2015, 4, 27, 16, 55, 0);
        investigation.Due_Date__c = fixedDueDateTime.date();
        update investigation;        
        
        // Phase II. Get current SLA due date.        
        DateTime oldDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;
        
        // Phase III. Make a feed comment with #nosla.
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            FeedComment commment = generateTestFeedComment(post.Id, 'Still investigating #nosla');
        }
        
        DateTime newDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;        
        
        System.assertEquals(oldDueTime.getTime(), newDueTime.getTime());
        
        Test.stopTest();
    }
    
    @isTest static void ftest_FeedItemDontInvokeDueDateReset() {
        // insert some data
        ADM_Work__c investigation = generateTestInvestigation();
        
        Test.startTest();
        
        // Phase I. Change Due Date Time back to a time, so that our reset code not depend on the time we run the code.
        DateTime fixedDueDateTime = Datetime.newInstance(2015, 4, 27, 16, 55, 0);
        investigation.Due_Date__c = fixedDueDateTime.date();
        update investigation;        
        
        // Phase II. Get current SLA due date.        
        DateTime oldDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;
        
        // Phase III. Make a feed item with #nosla.
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            FeedItem post = generateTestFeedItem(investigation.Id, 'Made a lot of progress #nosla');
        }
        
        DateTime newDueTime = [SELECT Due_Date__c FROM ADM_Work__c WHERE Id = :investigation.Id ].Due_Date__c;        
        
        System.assertEquals(oldDueTime.getTime(), newDueTime.getTime());
        
        Test.stopTest();
    }
    
    /****** HELPER METHODS ******/
    
    static ADM_Work__c generateTestInvestigation(){
        ADM_Scrum_Team__c team = ADM_WorkSLATestData.createTeamWithBHS('scrum team', null, true);
        ADM_Work__c investigation = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV2, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING, team.Id, null, false);
        insert investigation;
        return investigation;
    }
    
    static FeedItem generateTestFeedItem(String workId, String body){
        FeedItem feedItem = new FeedItem(ParentId=workId, Body=body);
        insert feedItem;
        return feedItem;
    }
    
    static FeedComment generateTestFeedComment(String feedItemId, String commentBody){
        FeedComment commment = new FeedComment(FeedItemId=feedItemId, CommentBody=commentBody);
        insert commment;
        return commment;
    }
}