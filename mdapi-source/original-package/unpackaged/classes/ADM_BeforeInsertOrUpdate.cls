public with sharing class ADM_BeforeInsertOrUpdate {
    
    public static void clearPerforceStatusOnChanges(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld) {
        Boolean hasChange = false;
        
        for(Integer i = 0; i < worksNew.size(); i++) {
            hasChange = false;
            ADM_Work__c newWork = worksNew[i];
            ADM_Work__c oldWork = worksOld[i];
            
            if(oldWork.Perforce_Status__c == newWork.Perforce_Status__c) { 
                if(newWork.Scheduled_Build__c != oldWork.Scheduled_Build__c) {
                    hasChange = true;
                }
                if(newWork.Assignee__c != oldWork.Assignee__c) {
                    hasChange = true;
                }
            }
            
            if(hasChange) newWork.Perforce_Status__c = null;
        }
    }
    
    public static void setDefaultValues(ADM_Work__c[] works, Map<Id,RecordType> workRecordTypesById) {
        //any values that you would like defaulted at the trigger level are set here.  Note: please make sure the value
        //makes sense for records created from all origins (Salesforce Classic, LEX, API, S1)
        for(ADM_Work__c work : works) {
            String recordTypeName = workRecordTypesById.get(work.RecordTypeId).Name;
            if(recordTypeName != null) {
                //if this is a Bug and the Bug Type picklist has not been populated assume its a generic bug vs Test Chanage etc
                if(recordTypeName == 'Bug' && (work.Type__c == null || work.Type__c.trim() == '')) {
                    work.Type__c = 'Bug';
                } 
            }
        }
    }
}