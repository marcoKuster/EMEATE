trigger ADM_FeatureFreezeTeamStatusTrigger on ADM_Feature_Freeze_Status__c (after insert) {
	
	
	ADM_FeatureFreezeUtils.updateFeatureFreezeStatus(Trigger.new);
	
	

}