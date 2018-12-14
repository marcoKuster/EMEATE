public with sharing class ADM_WorkDialogController {

    public static String getBaseUrl(){
        return System.Url.getSalesforceBaseUrl().toExternalForm();
    }


    @RemoteAction
    public static ADM_Work.WorkEditorDialogMetaData getWorkEditorDialogMetaData(String Id, String teamId){
        return ADM_Work.getWorkEditorDialogMetaData(Id, teamId);
    }

    @RemoteAction
    public static ADM_WorkAssignment.AssignmentContext getProductTagAutoAssignees(String severityLevel, String productTagId, String recordTypeName){
        ADM_Product_Tag__c pTag = new ADM_Product_Tag__c();
        pTag.Id = productTagId;
        RecordType rType = new RecordType();
        rType.Id = ADM_RecordType.getId(recordTypeName);
        return ADM_WorkAssignment.getAssignments(severityLevel, pTag, rType, null, null);
    }

    @RemoteAction
    public static SaveWorkError saveWork(ADM_Work__c work, Boolean kanban, String workType){
        system.debug('1- Account =' + work.account__c); 
        Database.Saveresult result;
        system.debug('Calling name to id conversion');        
        work = ADM_Work.convertNameToIdForAutoCompleteFields(work);
        system.debug('2- Account =' + work.account__c);
        system.debug('2- AccountName =' + work.account__r.name);
        //work dialog will be used in other places besides kanban board in the future so can't assume saves orinate from kanban board
        if(kanban) {
             work.Origin__c = ADM_WorkTriggerStaticDataStore.KANBAN_BOARD_ORIGIN;
        }
        work.RecordTypeId = ADM_RecordType.getByName(workType, 'ADM_Work__c').Id;
        if(work.id == null){
            result = Database.insert(work);
        }else{
            result = Database.update(work);
        }
        SaveWorkError swr = new SaveWorkError();
        
        if(result != null && !result.isSuccess()) {
            swr.work = work;
            swr.errorMessages = new List<String>();
            for(Database.Error error : result.getErrors()) {
                swr.errorMessages.add(error.getMessage());
            }        
        }

        return  swr;
    }
    
    
    public class SaveWorkError{
        ADM_Work__c work;
        List<String> errorMessages;
    }


}