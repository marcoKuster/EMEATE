/**
 * Scheduled job that deletes ADM_Deleted_Task entries that are older than
 * 24 hours.
 */ 
public class ADM_DeletedTaskScheduledJob implements Schedulable {
    public void execute(SchedulableContext sc) {
    	DateTime olderThan = (DateTime.now()).addHours(-24);
        ADM_DeletedTask.deleteDeletedTasksOlderThan(olderThan);
    }
}