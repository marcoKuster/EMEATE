public with sharing class ADM_StoryControllerGlobalAction extends ADM_WorkControllerGlobalAction{
	
	public ADM_StoryControllerGlobalAction(){
		ADM_Work__c newWork = new ADM_Work__c();
        setDefaultValues(newWork);
        work = newWork;
	}
	
	private void setDefaultValues(ADM_Work__c newWork){
    	newWork.Use_Prioritizer__c = true;
    	newWork.Type__c = 'User Story';
    	newWork.RecordTypeId = ADM_RecordType.ensureByName('User Story', 'ADM_Work__c').Id;
    }

}