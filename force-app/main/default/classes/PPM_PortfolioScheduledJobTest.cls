@IsTest
public class PPM_PortfolioScheduledJobTest {
    
    static testMethod void testEpicBurndownOpen() {

        ADM_Epic__c epic = ADM_Epic.createTestEpic();

        ADM_Work__c test_story =  ADM_Work.setupTestWork('User Story');
        test_story.Epic__c = epic.Id; 
        upsert test_story;
        
        ADM_Work__c test_bug =  ADM_Work.setupTestWork('Bug');
        test_bug.Epic__c = epic.Id; 
        upsert test_bug;

        Test.startTest();       
        
        PPM_PortfolioScheduledJob job = new PPM_PortfolioScheduledJob();
            job.execute(null);

        Test.stopTest();

        // There should be two items in the open state
        List<ADM_Epic_Burndown_Item__c> epic_burn = [SELECT Id,Status__c FROM ADM_Epic_Burndown_Item__c WHERE Epic__c =:epic.Id];  
        System.assertEquals( 2 , epic_burn.size());
        System.assertEquals( 'Open' , epic_burn.get(0).Status__c);
        System.assertEquals( 'Open' , epic_burn.get(1).Status__c);

    }

    static testMethod void testEpicBurndownClosed() {

        ADM_Epic__c epic = ADM_Epic.createTestEpic();
   
        ADM_Work__c test_story =  ADM_Work.setupTestWork('User Story');
        test_story.Epic__c = epic.Id; 
        test_story.Status__c = 'Closed';
        upsert test_story;
        
        ADM_Work__c test_bug =  ADM_Work.setupTestWork('Bug');
        test_bug.Epic__c = epic.Id; 
        test_bug.Status__c = 'Closed';
        upsert test_bug;

        Test.startTest();       
        
        PPM_PortfolioScheduledJob job = new PPM_PortfolioScheduledJob();
            job.execute(null);

        Test.stopTest();

        List<ADM_Epic_Burndown_Item__c> epic_burn = [SELECT Id,Status__c FROM ADM_Epic_Burndown_Item__c WHERE Epic__c =:epic.Id];  
        System.assertEquals( 2 , epic_burn.size());
        System.assertEquals( 'Closed' , epic_burn.get(0).Status__c);
        System.assertEquals( 'Closed' , epic_burn.get(1).Status__c);

    }

    static testMethod void testEpicBurndownStoryPoint() {

        ADM_Epic__c epic = ADM_Epic.createTestEpic();

        ADM_Work__c test_story =  ADM_Work.setupTestWork('User Story');
        test_story.Epic__c = epic.Id; 
        test_story.Story_Points__c = 3;
        upsert test_story;
        
        Test.startTest();       
        
        PPM_PortfolioScheduledJob first_job = new PPM_PortfolioScheduledJob();
            first_job.execute(null);

        Test.stopTest();

        List<ADM_Epic_Burndown_Item__c> epic_burn = [SELECT Id,Metric__c FROM ADM_Epic_Burndown_Item__c WHERE Epic__c =:epic.Id];  
        System.assertEquals( 1 , epic_burn.size());
        System.assertEquals( 3 , epic_burn.get(0).Metric__c);

    }

}