public with sharing class ADM_PushTopic {

    /**
     * Checks to see if a PushTopic exists with the specified properties. If one
     * exists with the specified name but the other properties are different, the
     * PushTopic is updated. If one does not exist, a new one is created. 
     */
    public static void ensurePushTopic(String name, String query, Double apiVersion, String notifyForOperations, String notifyForFields) {
        List<PushTopic> pushTopics = [select Name, Query, ApiVersion, NotifyForOperations, NotifyForFields from PushTopic where Name = :name];
        Boolean isNew = false;
        PushTopic thisPushTopic = null;
        if(pushTopics.size() > 0) {
            thisPushTopic = pushTopics.get(0);
            System.debug('PushTopic  found.');
        } else {
        	isNew = true;
            thisPushTopic = new PushTopic(Name = name);
            System.debug('PushTopic not found. Creating it.');
        }
        
        if(thisPushTopic.Id == null) {
            
            thisPushTopic.Query = query;
            thisPushTopic.ApiVersion = apiVersion;
            if(notifyForOperations.equalsIgnoreCase('All')) {
                thisPushTopic.NotifyForOperationCreate = true;
                thisPushTopic.NotifyForOperationUpdate = true;
                thisPushTopic.NotifyForOperationUndelete = true;
                thisPushTopic.NotifyForOperationDelete = true;
            }
            
            thisPushTopic.NotifyForFields = notifyForFields;
            upsert thisPushTopic;
            
            if(isNew) {
            	System.debug('PushTopic has been created.');
            } else {
                System.debug('PushTopic has been updated.');
            }
        } 
    }

     
    
}