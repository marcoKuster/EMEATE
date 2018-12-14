trigger ADM_ApplicationTrigger on ADM_Application__c (before insert, before update, after insert, after update) {
	
	// set Duplicate_Application_Name__c (a unique-ified field) to the Application name in order to detect duplicates
	if (Trigger.isBefore) {
			// set Duplicate_Application_Name__c (a unique-ified field) to the Application name in order to detect duplicates
            for(ADM_Application__c app : Trigger.new) {
                String appNameNoPunc = ADM_DuplicateValidator.removeAllPunctuationAndWhitespace(app.Name);
                app.Duplicate_Application_Name__c = appNameNoPunc;
            }
	}
	if (Trigger.isAfter) {
		// Ensure that there is always a base release event Template
		
		List<ADM_Release_Event_Template__c> baseRetToInsert = new List<ADM_Release_Event_Template__c>();
		List<ADM_Release_Event_Template__c> retList = [select Application__c, Release_Type__c, Event_Duration__c,
			Day_Offset__c, Minute_Offset__c, Hour_Offset__c from ADM_Release_Event_Template__c 
			where Application__c =: Trigger.newMap.keySet()];

		// Build App to Release Event Template List map
		Map</*Application*/ Id, List<ADM_Release_Event_Template__c>> appToRetList = new Map<Id, List<ADM_Release_Event_Template__c>>();
		for (ADM_Release_Event_Template__c ret : retList) {
			List<ADM_Release_Event_Template__c> retL = appToRetList.get(ret.Application__c);
			if (retL == null) {
				List<ADM_Release_Event_Template__c> newRetL = new List<ADM_Release_Event_Template__c>();
				newRetL.add(ret);
				appToRetList.put(ret.Application__c, newRetL);
			} else {
				retL.add(ret);
				appToRetList.put(ret.Application__c, retL);
			}
		}
		for (ADM_Application__c app : Trigger.new) {
			List<ADM_Release_Event_Template__c> retL = appToRetList.get(app.id);
			if (retL == null) {
				ADM_Release_Event_Template__c retToAdd = ADM_ReleaseEventTemplate.setupBaseReleaseEventTemplate(app);
				baseRetToInsert.add(retToAdd);
			} else {
				Set<String> releaseTypeSet = new Set<String> {		// Make sure all types have a Base Event
						ADM_ReleaseEventTemplate.RELEASE_TYPE_MAJOR,
						ADM_ReleaseEventTemplate.RELEASE_TYPE_PATCH,
						ADM_ReleaseEventTemplate.RELEASE_TYPE_ERELEASE,
						ADM_ReleaseEventTemplate.RELEASE_TYPE_OTHER 
				};
				for (ADM_Release_Event_Template__c ret : retL) {
					if (ADM_ReleaseEventTemplate.isBaseEventTemplate(ret)) {
						for (String releaseType : releaseTypeSet) {
							if (ret.Release_Type__c != null && ret.Release_Type__c.contains(releaseType)) {
								releaseTypeSet.remove(releaseType);
							}
						}
					}
				}
				String baseReleaseType = '';
				for (String releaseType : releaseTypeSet) {
					if (baseReleaseType.length() > 0) {
						baseReleaseType += ';';		// Add a separator
					}
					baseReleaseType += releaseType;
				}
				if (baseReleaseType.length() > 0) {
					ADM_Release_Event_Template__c retToAdd = ADM_ReleaseEventTemplate.setupBaseReleaseEventTemplate(app);
					retToAdd.Release_Type__c = baseReleaseType;
					baseRetToInsert.add(retToAdd);
				}
			}
		}
		/* DEBUG OFF
		System.debug('ADM_ApplicationTrigger: baseRetToInsert =' + baseRetToInsert);
		/* DEBUG */
		if (baseRetToInsert.size() > 0) {
			try {
				insert baseRetToInsert;
	    	} catch (Exception e) {
	    		System.debug('ADM_ApplicationTrigger: Insert of Base Release Event Template failed for in Application trigger. ' + 
	    			e + ' - ' + baseRetToInsert);
	    	}			
		}	
	}

}