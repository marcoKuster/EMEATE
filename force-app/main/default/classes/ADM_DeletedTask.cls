public class ADM_DeletedTask {
    /**
     * Deletes the ADM_Deleted_Task entries that were created before the 
     * DateTime specified.
     */
    public static void deleteDeletedTasksOlderThan(DateTime olderThan) {
        List<ADM_Deleted_Task__c> toBeDeleted = [select Id from ADM_Deleted_Task__c where CreatedDate < :olderThan];
        delete toBeDeleted;
    }

}