@IsTest
public class ADM_Investigation_Ack_ControllerTest {

    @isTest
    static void testGetSLADueTimeDiff() {
        
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
       
        // padding all times by 30 sec to prevent failed assertions due to clock timing
        
        Test.startTest();
        work.Due_Date__c = null;
        System.assertEquals('', ADM_Investigation_Ack_Controller.getSLADueTimeDiff( work ));
        
        work.Due_Date__c = System.now().addSeconds(1*60 + 30);
        System.assertEquals('Due in 1 minute ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(5*60 + 30);
        System.assertEquals('Due in 5 minutes ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(1*3600 + 30);
        System.assertEquals('Due in 1 hour ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(4*3600 + 30);
        System.assertEquals('Due in 4 hours ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(1*24*3600 + 30);
        System.assertEquals('Due in 1 day ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(4*24*3600 + 30);
        System.assertEquals('Due in 4 days ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(10*3600 + 29*60 + 30);
        System.assertEquals('Due in 10 hours 29 minutes ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(2*24*3600 + 10*3600 + 29*60 + 30);
        System.assertEquals('Due in 2 days 10 hours 29 minutes ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
        
        work.Due_Date__c = System.now().addSeconds(-(9*60 + 30));
        System.assertEquals('Overdue by 9 minutes ', ADM_Investigation_Ack_Controller.getSLADueTimeDiff(work));
    }
    
}