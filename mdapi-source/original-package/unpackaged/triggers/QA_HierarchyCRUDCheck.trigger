trigger QA_HierarchyCRUDCheck on QA_Hierarchy__c (before insert, before update, before delete) {
	ADM_CRUDChecker admCrudChecker = new ADM_CRUDChecker('QA_Hierarchy__c');
    if(!admCrudChecker.checkPermsBeforeDML(Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, (List<SObject>) Trigger.new, (Map<Id, SObject>) Trigger.oldMap)){
    	throw new ADM_ApplicationException('User has insufficient access to '+ 'QA_Hierarchy__c');
    }
}