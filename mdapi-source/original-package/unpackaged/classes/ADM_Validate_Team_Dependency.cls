public with sharing class ADM_Validate_Team_Dependency {
	public static List<String> getWorkIdsFromTeamDependencies(List<ADM_Team_Dependency__c> els) {
		List<String> ids = new List<String>();
		
		for(ADM_Team_Dependency__c el : els) {
			if(el.Provider_User_Story__c != null) {
				ids.add(el.Provider_User_Story__c);
			}
			if(el.Dependent_User_Story__c != null) {
				ids.add(el.Dependent_User_Story__c);
			}
		}
		return ids;
	}
    
    public static void validateTeamDependencies(List<ADM_Team_Dependency__c> elsOld, Map<Id,ADM_Team_Dependency__c> elsNew) {
    	List<String> workIDs = getWorkIdsFromTeamDependencies(elsOld);
    	if(workIDs != null && workIDs.size() > 0) {
	    	Map<Id,ADM_Work__c> work = new Map<Id,ADM_Work__c>([select id, RecordType.Name from ADM_Work__c where id in:workIDs]);
	        if(work != null && work.size() > 0) {
		        for(ADM_Team_Dependency__c elOld : elsOld) {
		            // Validation check to make sure that provider user story is on the correct backlog.
		            if(elOld.Dependent_User_Story__r.Scrum_Team__c != null) {
		                if(elOld.Dependent_User_Story__r.Scrum_Team__c != elOld.Dependent_Team__c) {
		                    elsNew.get(elOld.Id).Dependent_User_Story__c.addError('This User Story must be on the backlog of the team with the dependency.');
		                }
		                if(work.get(elOld.Dependent_User_Story__c).RecordType.Name == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
		                    elsNew.get(elOld.Id).Dependent_User_Story__c.addError('Work templates cannot be assigned to team dependencies.');
		                }
		            }
		            // Validation check to make sure that dependent user story is on the correct backlog.
		            if(elOld.Provider_User_Story__r.Scrum_Team__c != null) {
		                if(elOld.Provider_User_Story__r.Scrum_Team__c != elOld.Provider_Team__c) {
		                    elsNew.get(elOld.Id).Provider_User_Story__c.addError('This User Story must be on the backlog of the team providing the deliverable.');
		                }
		                if(work.get(elOld.Provider_User_Story__c).RecordType.Name == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
		                    elsNew.get(elOld.Id).Provider_User_Story__c.addError('Work templates cannot be assigned to team dependencies.');
		                }
		            }
		        }
	        }    
    	}    
    }

}