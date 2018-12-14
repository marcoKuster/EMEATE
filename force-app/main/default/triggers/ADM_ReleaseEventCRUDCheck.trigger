trigger ADM_ReleaseEventCRUDCheck on ADM_Release_Event__c (before insert, before update, before delete) {
	ADM_CRUDChecker admCrudChecker = new ADM_CRUDChecker('ADM_Release_Event__c');
    if(!admCrudChecker.checkPermsBeforeDML(Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, (List<SObject>) Trigger.new, (Map<Id, SObject>) Trigger.oldMap)){
    	throw new ADM_ApplicationException('User has insufficient access to '+ 'ADM_Release_Event__c');
    }
}