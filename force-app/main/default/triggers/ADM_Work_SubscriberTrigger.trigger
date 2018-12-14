trigger ADM_Work_SubscriberTrigger on ADM_Work_Subscriber__c (after insert, after delete) {

	Set<Id> parentWorkIds = new Set<Id>(); 
	Map<String,Set<String>> separatedIDAndNonIDSubscribersFromWork = new Map<String,Set<String>>();
	Set<String> nonIds = new Set<String>();
	Set<String> ids = new Set<String>();
	Map<String, Set<String>> workId2OtherRecipientIdOrEmail = new Map<String, Set<String>>();
	Set<String> subscriberIdOrEmailSet;
	List<ADM_Work_Subscriber__c> workSubscribers = new List<ADM_Work_Subscriber__c>();

	if(Trigger.isInsert){
		workSubscribers = Trigger.newMap.values();
	}
	else if(Trigger.isDelete){
		workSubscribers = Trigger.oldMap.values();
	}

	
	for (ADM_Work_Subscriber__c so : workSubscribers) {
		String workId = so.WorkId__c;
		String userId = so.userId__c;
		String email  = so.Distribution_List__c;
		subscriberIdOrEmailSet = new Set<String>();
		if(so.userId__c != null && UserInfo.getUserId() == so.userId__c){//ignoring current users
			continue;
		}
		else{
			
			parentWorkIds.add(workId);
			ids.add(userId);
			nonIds.add(email);
		}

		subscriberIdOrEmailSet =  workId2OtherRecipientIdOrEmail.get(workId);
		if(null != subscriberIdOrEmailSet){
			subscriberIdOrEmailSet.add(userId);
			subscriberIdOrEmailSet.add(email);
		}
		else{
				subscriberIdOrEmailSet = new Set<String>();
				subscriberIdOrEmailSet.add(userId);
				subscriberIdOrEmailSet.add(email);
		}
		subscriberIdOrEmailSet.remove(null);//removing null before adding to map
		workId2OtherRecipientIdOrEmail.put(workId,subscriberIdOrEmailSet);

	}
	


	//Removing nulls if any from the collections

	parentWorkIds.remove(null);
	nonIds.remove(null);
	ids.remove(null);

	if(ids.size() > 0){
		separatedIDAndNonIDSubscribersFromWork.put('id',ids);
	}

    if(nonIds.size() > 0){
        separatedIDAndNonIDSubscribersFromWork.put('username,email,alias',nonIds);
    }

    if(Trigger.isInsert){
	    ADM_Work_Subscriber.addWorkEntitySubscribers(parentWorkIds,separatedIDAndNonIDSubscribersFromWork,workId2OtherRecipientIdOrEmail);
	}
	else if(Trigger.isDelete){
		ADM_Work_Subscriber.removeWorkEntitySubscribers(parentWorkIds,separatedIDAndNonIDSubscribersFromWork,workId2OtherRecipientIdOrEmail);
	}

}