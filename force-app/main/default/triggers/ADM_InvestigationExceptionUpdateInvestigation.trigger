trigger ADM_InvestigationExceptionUpdateInvestigation on ADM_Investigation_Exception__c (after insert, after update) {
	List<String> workIds = new List<String>();
	Set<String> userIds = new Set<String>();
	
	//retrieve the information that will be used for bulk look up
	for(ADM_Investigation_Exception__c ex : trigger.new) {
		workIds.add(ex.Investigation__c);
		
		if(ex.Assigned_To__c != null) {
			userIds.add(ex.Assigned_To__c);
		}
	}
	
	//retrieve the information for bulk look up from previous records
	if(trigger.isUpdate) {
		for(ADM_Investigation_Exception__c ex : trigger.old) {
			if(ex.Assigned_To__c != null) {
				userIds.add(ex.Assigned_To__c);
			}
		}
	}
	
	//bulk retrieve the users
	List<User> users = [select Id, Name from User where Id in :userIds];
	Map<String, User> userMapById = new Map<String, User>();
	for(User user : users) {
		userMapById.put(user.Id, user);
	}
	
	//bulk retrieve the work records
	Map<Id,ADM_Work__c> workMapById = ADM_Work.getAllByAsMap('Id', workIds, 0, workIds.size(), 'Id', 'ASC');
	
	List<ADM_Work__c> workNeedingUpdated = new List<ADM_Work__c>();
	Set<Id> ids = new Set<Id>();

	for(ADM_Investigation_Exception__c ex : trigger.new) {
		
		if(workMapById.containsKey(ex.Investigation__c)) {
			String exUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ex.Id;
			
			//add a new comment to the related work object
			List<String> comments = new List<String>();
			
			if(trigger.isInsert) {
				//add a comment to the work record when a new exception is added
				if(ex.Assigned_To__c != null && userMapById.containsKey(ex.Assigned_To__c)) {
					User assignedTo = userMapById.get(ex.Assigned_To__c);
					comments.add('New exception request created and assigned to ' + assignedTo.Name + '.');
				} else {
					comments.add('New exception request created.');
				}
				
			} else if(trigger.isUpdate) {
				ADM_Investigation_Exception__c previous = trigger.oldMap.get(ex.Id);
				
				//if the status has changed, then add a new comment to the work record
				if(ex.Status__c != previous.Status__c) {
					if(!ADM_TextUtils.isBlank(previous.Status__c) && !ADM_TextUtils.isBlank(ex.Status__c)) {
						comments.add('Exception request status changed from ' + previous.Status__c + ' to ' + ex.Status__c + '.');
					} else if(!ADM_TextUtils.isBlank(ex.Status__c)) {
						comments.add('Exception request status changed to ' + ex.Status__c + '.');
					}
				}
				
				//if the assignee has changed, then add a comment to the work record
				if(ex.Assigned_To__c != previous.Assigned_To__c) {
					User previousAssignee = null;
					User currentAssignee = null;
					
					if(userMapById.containsKey(previous.Assigned_To__c)) {
						previousAssignee = userMapById.get(previous.Assigned_To__c);
					}
					
					if(userMapById.containsKey(ex.Assigned_To__c)) {
						currentAssignee = userMapById.get(ex.Assigned_To__c);
					}
					
					if(previousAssignee != null && currentAssignee != null) {
						comments.add('Exception request assignee changed from ' + previousAssignee.Name + ' to ' + currentAssignee.Name + '.');
					} else if(currentAssignee != null) {
						comments.add('Exception request assignee changed to ' + currentAssignee.Name + '.');
					}
				}
			}
			
			if(!comments.isEmpty()) {
				// Keep track of the Investigations we've already added to the
				// workNeedingUpdated List
				ADM_Work__c work = workMapById.get(ex.Investigation__c);
				
				String comment = '';
				for(String commentLine : comments) {
					comment += commentLine + '\n';
				}
				comment += '\n' + exUrl;
				
				System.debug('Adding a comment to investigation[' + work.Id + ']: ');
				if (ids.contains(work.Id)) {

					System.debug('This investigation [' + work.Id + '] already in bulk update list, modifying in place');

					// This Investigation has had a comment already added to it,
					// so just update the existing record and append the new comment
					work.Description__c += ('\n\n' + comment);

				} else {
					System.debug('Add this Investigation [' + work.Id + '] to the bulk update list');
					// This Investigation doesn't exist in the bulk update list yet,
					// so process as usual.
					work.Description__c = comment;
					workNeedingUpdated.add(work);
					ids.add(work.Id);
				}
			}
		}
	}
	
	//batch update the work
	Database.update(workNeedingUpdated);
}