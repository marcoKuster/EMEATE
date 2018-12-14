public with sharing class ADM_BugControllerGlobalAction  extends ADM_WorkControllerGlobalAction {
	
	public ADM_BugControllerGlobalAction(){
		ADM_Work__c newWork = new ADM_Work__c();
        setDefaultValues(newWork);
        work = newWork;
	}
	 
	private void setDefaultValues(ADM_Work__c newWork){
    	newWork.Type__c = 'Bug';
    	newWork.RecordTypeId = ADM_RecordType.ensureByName('Bug', 'ADM_Work__c').Id;
    }
}