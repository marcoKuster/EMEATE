trigger ADM_ColumnTrigger on ADM_Column__c (before insert, before update) {
	ADM_ColumnUtility.validateColumnsBeforeDML(Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.oldMap);
}