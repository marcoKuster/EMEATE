@isTest
public with sharing class ADM_TaskDeletingTriggerTests {

   /*
	  @testcaseID ID: a1DB00000002bwx
	  @hierarchy GUS.Social Sprint.Warnings
	  @userstory a07B0000000NdhL
	  @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again
	  @author jhatton
	*/
	
    static testMethod void testDeletedTaskCreationOnDelete() {
        ADM_Work__c work = ADM_Work.createTestBug();
        User assignee = ADM_WorkUser.createTestUser();
        ADM_Task__c task = new ADM_Task__c();
        task.Subject__c = 'Task to be deleted';
        task.Work__c = work.Id;
        task.Assigned_To__c = assignee.Id;
        insert task;
        
        delete task;
        
        List<ADM_Deleted_Task__c> deletedTasks = [select Work__c, Task__c from ADM_Deleted_Task__c where Task__c = :task.Id];
        System.assert(deletedTasks.size() > 0, 'Expected a Deleted Task entry to be added when the Task is deleted.');
    } 
    
}