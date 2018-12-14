@isTest
public class ADM_WorkUnsubscriberTest {
    
    
    static ADM_Work__c getWorkWithSubscribers(){
        List<ADM_ChangeListMessage.Recipient> recipients;
        Set<String> recipientEmails = new Set<String>();
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1');
        User assignee = ADM_WorkUser.setupTestUser();
        User qa = ADM_WorkUser.setupTestUser();
        User productOwner = ADM_WorkUser.setupTestUser();
        User techWriter = ADM_WorkUser.setupTestUser();
        User seniorManagerPOC = ADM_WorkUser.setupTestUser();
        User systemTestEngineer = ADM_WorkUser.setupTestUser();
        User ueEngineer = ADM_WorkUser.setupTestUser();

        User subscriber1 = ADM_WorkUser.setupTestUser();
        User subscriber2 = ADM_WorkUser.setupTestUser();
        User subscriber3 = ADM_WorkUser.setupTestUser();
        

        subscriber1.userName = 'tuser@gus.com'+Math.random();

        String alias = 'a'+Math.random();
        subscriber3.alias = (alias.length() >=0)?alias.substring(0,8):alias;

        assignee.Email = 'test1@test.com';
        qa.Email = 'test2@test.com';
        productOwner.Email = 'test3@test.com';
        techWriter.Email = 'test4@test.com';
        seniorManagerPOC.Email = 'test5@test.com';
        systemTestEngineer.Email = 'test7@test.com';
        ueEngineer.Email = 'test8@test.com';

        subscriber1.Email = 'subscriber1@test.com';
        subscriber2.Email = 'subscriber2@test.com';
        subscriber3.Email = 'subscriber3@test.com';



        insert new User[]{assignee,qa,productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer,subscriber1,subscriber2,subscriber3};



        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;

        work.Email_Subscription_ID__c = subscriber1.userName + ',' + subscriber2.Email + ',' + subscriber3.alias;
        insert work;
        return work;
    }
    
    testMethod static void testVerifyUnsubscriberDeleteSubscriptionForClosedWorkRecords() {
        
        ADM_Work__c work = getWorkWithSubscribers();
        

        EntitySubscription[] entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());
        
        //Make sure Entity Subscription was created
        System.assertEquals(10,entitySubscribers.size(), '10 entity subscribers expected - 7 assigned users and 3 subscribers through Email_Subscription_ID__c field ');
        
        //Closing the work record
        work.status__c = 'Closed';
        
        update work;//Work is now closed.
        
        
        
        Schedulable scheduledUnSubscriber = new ADM_WorkUnsubscriber();
         
        
        scheduledUnSubscriber.execute(null);
        
        entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());
        
        //Make sure Entity Subscription still exists
        System.assertEquals(0,entitySubscribers.size(), '0 entity subscribers expected - As unsubscriber utility should delete all subscribers - work is  in closed status, and modified today ');
        
    }
    
    testMethod static void testVerifyUnsubscriber_WontDeleteIfWorkIsNotClosed() {
        
        ADM_Work__c work = getWorkWithSubscribers();
        
        EntitySubscription[] entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());
        
        //Make sure Entity Subscription was created
        System.assertEquals(10,entitySubscribers.size(), '10 entity subscribers expected - 7 assigned users and 3 subscribers through Email_Subscription_ID__c field ');
        
                
        Schedulable scheduledUnSubscriber = new ADM_WorkUnsubscriber();
         
        ADM_Key_Value_Properties__c testKey_Value = new ADM_Key_Value_Properties__c();
        testKey_Value.Name = 'UnSubscribe_Closed_Work_After';
        testKey_Value.value__c = '0'; //setting the value to 0 for the test method so that it will point to work created during the test run
        testKey_Value.Property_Description__c = 'test value';
        
        
         
        ADM_Key_Value_Properties__c[] key_value = [Select value__c from ADM_Key_Value_Properties__c where Name = 'UnSubscribe_Closed_Work_After' limit 1];
        
        if(key_value.size() ==0 ){
            key_value.add(testKey_Value);
        }
        else{
            key_value[0] = testKey_Value;
        }
        
        
        upsert key_value;
        
        scheduledUnSubscriber.execute(null);
        
        entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());
        
        //Make sure Entity Subscription was created
        System.assertEquals(10,entitySubscribers.size(), '10 entity subscribers expected - As unsubscriber utility should not delete any subscribers as work is not closed');
        
    }
    
   
    
    


}