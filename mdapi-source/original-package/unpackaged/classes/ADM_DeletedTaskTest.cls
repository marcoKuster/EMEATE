@IsTest
public class ADM_DeletedTaskTest {

	@IsTest    
	static void testDeleteDeletedTasksOlderThan() {
		ADM_Deleted_Task__c task = new ADM_Deleted_Task__c();
		task.Name = 'T-0001';
		task.Work__c = '0F9B000000001Ex';
		task.Task__c = '0F9B000000001Ex';
		insert task;
		
		//create a time in the future
		DateTime olderThan = (DateTime.now()).addHours(24);
		
		ADM_DeletedTask.deleteDeletedTasksOlderThan(olderThan);
		
		List<ADM_Deleted_Task__c> tasks = [select Id from ADM_Deleted_Task__c where Id = :task.Id];
		System.assert(tasks.size() == 0, 'Expected the entry to be deleted because it is older than the specified date');
	}
	
    @IsTest
    static void testDeleteDeletedTasksOlderThanWithNewRecord() {
        ADM_Deleted_Task__c task = new ADM_Deleted_Task__c();
        task.Name = 'T-0001';
        task.Work__c = '0F9B000000001Ex';
        task.Task__c = '0F9B000000001Ex';
        insert task;
        
        //create a time in the past
        DateTime olderThan = (DateTime.now()).addHours(-1);
        
        ADM_DeletedTask.deleteDeletedTasksOlderThan(olderThan);
        
        List<ADM_Deleted_Task__c> tasks = [select Id from ADM_Deleted_Task__c where Id = :task.Id];
        System.assert(tasks.size() == 1, 'Expected the entry to not be deleted because it is newer than the specified date');
    }
    
}