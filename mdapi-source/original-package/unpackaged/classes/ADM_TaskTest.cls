@isTest
public class ADM_TaskTest {

    /**
     * Test that makes sure a PushTopic is created when no other PushTopic already
     * exists.
     */
    @isTest
    static void testEnsureTaskUpdatesPushTopicWithoutExisting() {
        
        String taskName = 'TaskUpdates' + System.currentTimeMillis();

        //create the push topic
        ADM_Task.ensureTaskUpdatesPushTopic( taskName );
  
        List<PushTopic> pushTopics = [select Id, Name from PushTopic where Name = :taskName];

        System.assertEquals(1, pushTopics.size(), 'Expected the TaskUpdates PushTopic to be created');
    }
    
    /**
     * Test that makes sure calling ensureTaskUpdatesPushTopic does not fail when
     * a PushTopic already exists.
     */
    @isTest
    static void testEnsureTaskUpdatesPushTopicWithExisting() {
        
        String taskName = 'TaskUpdates' + System.currentTimeMillis();        

        //create a push topic with the work updates name
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = taskName;
        pushTopic.Query = 'select Id, Name from ADM_Task__c';
        pushTopic.ApiVersion = 25.0;
        //pushTopic.NotifyForOperations = 'All';
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;
        
        //create the push topic
        ADM_Task.ensureTaskUpdatesPushTopic( taskName );
        
        List<PushTopic> pushTopics = [select Id, Name, Query from PushTopic where Name = :taskName];
        System.assertEquals(1, pushTopics.size(), 'Expected the TaskUpdates PushTopic to be created');
        System.assertEquals(pushTopic.Query, pushTopics.get(0).Query, 'Expected the query not to change during the call to ensureTaskUpdatesPushTopic');

    }
}