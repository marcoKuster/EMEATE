public with sharing class ADM_Task {
    public static String TASK_ERROR_NONEMPLOYEE = 'Quality task "<0>" cannot be assigned to non-employee. If assignee is an active employee of Salesforce please submit a concierge ticket to correct the employee record.';
    public static String TASK_STATUS_COMPLETED = 'Completed';

    /**
     * Creates the "TaskUpdates" PushTopic if it does not already exist otherwise,
     * a Debug message is logged.
     */
    public static void ensureTaskUpdatesPushTopic( String taskName ) {
        String name = taskName;
        String query = 'select Id, Subject__c, Status__c, Starting_Hours__c, Order__c, Hours_Remaining__c, External_ID__c, Due_By__c, Assigned_To__c, Actual_Hours__c,SprintId__c, LastModifiedDate, Work__c from ADM_Task__c';
        query = COM_SoqlUtils.convertToQualifiedQuery(query);
        Double apiVersion = 25.0;
        String notifyForOperations = 'All';
        String notifyForFields = 'All';

        ADM_PushTopic.ensurePushTopic(name, query, apiVersion, notifyForOperations, notifyForFields);
    }

    public static void ensureTaskUpdatesPushTopic() {
        ensureTaskUpdatesPushTopic('TaskUpdates');
    }

    public static ADM_Task__c setupTestTask(ADM_Work__c work) {
        ADM_Task__c task = new ADM_Task__c(Work__c = work.Id, Assigned_To__c = work.Assignee__c, Subject__c = 'Test Task');

        return task;
    }
}