trigger ADM_TaskDeletingTrigger on ADM_Task__c (before delete) {
	
	/**
	 * When a task is deleted, we need to record a Deleted Task entry because
	 * the Streaming clients need to know. We have a seperate object because
	 * v25.0 of the Streaming API does not support notifying subscribers on
	 * delete. 
	 */
	List<ADM_Deleted_Task__c> deletedTaskRecords = new List<ADM_Deleted_Task__c>();
	Set<Id> taskIds = Trigger.oldMap.keySet();
    Map<Id, ADM_Task__c> taskMap = new Map<Id, ADM_Task__c>([select Id, Name, Work__c from ADM_Task__c where ID in :taskIds]);
    for(Id taskId : taskIds) {
    	ADM_Task__c task = taskMap.get(taskId);
    	
    	ADM_Deleted_Task__c deletedLogRecord = new ADM_Deleted_Task__c();
    	deletedLogRecord.Name = task.Name;
    	deletedLogRecord.Work__c = task.Work__c;
    	deletedLogRecord.Task__c = task.Id;
    	deletedTaskRecords.add(deletedLogRecord);
    }
    
    insert deletedTaskRecords;
}