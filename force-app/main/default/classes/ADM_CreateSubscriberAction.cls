global class ADM_CreateSubscriberAction {
	// called by the before insert/update trigger
	public static boolean beforeInsertOrUpdate(ADM_Work__c[] works) {
		
        
		Boolean returnValue = true;
		Map <String, String> error = new Map <String, String>();
		Map<Id, List<String>> notFoundMap = new Map<Id, List<String>>();	
		Map<Id, ADM_Work__c> worksWithSubscriptions = new Map<Id, ADM_Work__c>();
		List<String> notFoundValues = new List<String>();
		
		for(ADM_Work__c work : works) {	
			work.Email_On_Save_Copy__c = work.Email_On_Save__c;
			work.Email_On_Save__c = false;
			
			if(work.Email_Subscription_ID__c != null && work.Email_Subscription_ID__c != '') {
				worksWithSubscriptions.put(work.Id, work);
			}
		}
		
		if(!worksWithSubscriptions.isEmpty()) {
			
			notFoundMap = ADM_Subscriber.getAllFromWork(worksWithSubscriptions);
									
			for(String key : notFoundMap.keySet()) {				
				notFoundValues = notFoundMap.get(key);
				Integer notFoundCount = 0;
				String message = '';
				
				if(notFoundValues != null && notFoundValues.size() > 1) {													
					message = 'The following values were ';
				} else if(notFoundValues != null && notFoundValues.size() == 1) {					
					message = 'The following value was ';	
				} else if(notFoundValues == null) {
					return returnValue;
				}
				
				returnValue = false;				
				message = message + ' not matched to a user name, email address, or alias in the system: ';
				
				for(String notFoundValue : notFoundValues) {																		
					notFoundCount++;
											
					if(notFoundCount > 1 && notFoundCount <notFoundValues.size()) message = message + ',';										
					message = message + ' ' + notFoundValue;					 	
				}				
				error.put('message', message);
					
				if(error.get('message') != '') {
					worksWithSubscriptions.get(key).Email_Subscription_ID__c.addError(error.get('message'));
				}						
				
				notFoundCount = 0;
				notFoundValues.clear();
				error.clear();
			}			
		}		
		
		
        
		return returnValue;
	}


	public static boolean wasEmailOnSaveSelected(ADM_Work__c work) {
		if(work.Email_On_Save_Copy__c) {
			return true;
		}
		
		return false;
	}

}