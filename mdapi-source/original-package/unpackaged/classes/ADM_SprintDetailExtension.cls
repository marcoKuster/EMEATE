public with sharing class ADM_SprintDetailExtension {
    
    public ADM_SprintDetailExtension(ApexPages.StandardController stdController) {
    }
    
    /**
     * Ensure the push topics used by the page are created
     */
    public void ensurePushTopics() {
        ADM_Work.ensureWorkUpdatesPushTopic();
        ADM_Task.ensureTaskUpdatesPushTopic();
        ensureDeletedTaskUpdatesPushTopic();
        ADM_Sprint.ensureSprintUpdatesPushTopic();
        ADM_Work.ensureWorkHistoryPushTopic();
    }
    
    private static void ensureDeletedTaskUpdatesPushTopic() {
        String name = 'DeletedTaskUpdates';
        String query = 'select Id, Name, Work__c, Task__c, LastModifiedDate from ADM_Deleted_Task__c';
        query = COM_SoqlUtils.convertToQualifiedQuery(query);
        ADM_PushTopic.ensurePushTopic(name, query, 25, 'All', 'All');
    }
    
    public Boolean getCurrentUserLightningDesktopPreference() {
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
    }

}