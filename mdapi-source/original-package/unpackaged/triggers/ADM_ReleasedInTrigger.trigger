trigger ADM_ReleasedInTrigger on ADM_Released_In__c (before insert) {
	
	//Before the insert of the stamp, we want to make sure the Stamped_On__c property is set to now
	if(Trigger.isBefore && Trigger.isInsert) {
		List<ADM_Released_In__c> releaseStamps = Trigger.new;
		
		for(ADM_Released_In__c releaseStamp : releaseStamps) {
			if(releaseStamp.Stamped_On__c == null) {
                releaseStamp.Stamped_On__c = System.now();
			}
		}
	}
}