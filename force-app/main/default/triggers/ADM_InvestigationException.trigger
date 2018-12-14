trigger ADM_InvestigationException on ADM_Investigation_Exception__c (before insert, before update) {
    List<String> workIds = new List<String>();
    List<String> productTagIDs = new List<String>();

    for(ADM_Investigation_Exception__c ex : trigger.new) {
        workIds.add(ex.Investigation__c);
    }
    //SOQL QUERIES #1
    Map<Id,ADM_Work__c> workMapById = ADM_Work.getAllByAsMap('Id', workIds, 0, workIds.size(), 'Id', 'ASC');
    //SOQL QUERIES #2
    Map<Id,RecordType> recordTypesByID = new Map<Id,RecordType>(ADM_RecordType.getAll());
    List<ADM_Work__c> works = (new ADM_AutoAssignWorkAction.Builder())
    	.withRecordTypes(recordTypesById)
    	.buildFor(workMapById.values())
    	.applyAssignmentRules(workMapById.values());

    for(ADM_Work__c work : works) {
        workMapById.put(work.Id, work);
        productTagIDs.add(work.Product_Tag__c);
    }
	//bulk lookup product tags - used to pull assignment rules later
	Map<Id, ADM_Product_Tag__c> tagMap = new Map<Id, ADM_Product_Tag__c>([select id, Name from ADM_Product_Tag__c where id in:productTagIDs]);
	
    //get the user that represents the product support managers
    User productionSupportManagers = null;
    List<User> users = ADM_WorkUser.getUsers('Name', new Set<String> {'Production Support Managers'});
    if(users.isEmpty()) {
    	throw new ADM_ApplicationException('No \'Production Support Managers\' user found');
    } else {
    	productionSupportManagers = users.get(0);
    }

    for(ADM_Investigation_Exception__c ex : trigger.new) {
        if(ex.Investigation__c != null) {
            ADM_Work__c work = workMapById.get(ex.Investigation__c);
            if(work.RecordType.Name != ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                ex.addError('Investigation exceptions must be related to work records that are ' + ADM_Work.RECORD_TYPE_NAME_INVESTIGATION + ' not ' + work.RecordType.Name);
            } else if(work.RecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION && work.Closed__c == 1 && Trigger.isInsert) {
                ex.addError('Investigation exceptions cannot be created for closed Investigations.');
            } else {
                if(ADM_TextUtils.isNull(ex.Requestor__c)) {
                  ex.Requestor__c = Userinfo.getUserId();
                }
                
                if(ADM_TextUtils.isNull(ex.Assigned_To__c)) {
                    //if "After Hours Triage", then always assign to "Product Support Managers"
                    if(ex.Type__c.toLowerCase().contains('after hours triage')) {
                        ex.Assigned_To__c = productionSupportManagers.Id;
                    } else if (ex.Type__c.toLowerCase().contains('sla violated by support') && work.CS_Contact__c != null && work.CS_Contact__r.ManagerId != null) {
                    	//if "SLA Violated by Support" then assign to the Investigations's customer support contact's manager
                        ex.Assigned_To__c = work.CS_Contact__r.ManagerId;
                    } else {
                        //If the Exception Request POC is entered on the assignment rule, then assign it to them
                        //otherwise assign it to the production support manager
                        ADM_AutoAssignWorkAction.Assignment assignment = ADM_AutoAssignWorkAction.createActionForTags(productTagIDs).getAssignments(tagMap.get(work.Product_Tag__c), true, false, false, recordTypesByID.get(work.RecordTypeId), work.severity_level__c);
                        
                        if(assignment != null && assignment.Exception_Request_POC != null) {
                            ex.Assigned_To__c = assignment.Exception_Request_POC.Id; 
                        } else {
                            ex.Assigned_To__c = productionSupportManagers.Id;
                        }
                    }
                }
                
            }
        } else {
            ex.addError('This exception does not have an associated Investigation record.');
        }
    }
}