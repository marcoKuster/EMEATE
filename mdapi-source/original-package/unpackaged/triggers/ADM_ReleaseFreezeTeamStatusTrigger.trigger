trigger ADM_ReleaseFreezeTeamStatusTrigger on ADM_Release_Freeze_Status__c (after insert) {

	ADM_ReleaseFreezeUtils.updateReleaseFreezeStatus(Trigger.new);
	

}