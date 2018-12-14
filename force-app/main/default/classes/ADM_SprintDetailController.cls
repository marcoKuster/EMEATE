public with sharing class ADM_SprintDetailController {

    public String getListViewLink() {
        Schema.DescribeSObjectResult sprintDescribe = Schema.SObjectType.ADM_Sprint__c;
        String objectPrefix = '/' + sprintDescribe.getKeyPrefix();
        
        return objectPrefix;
    }
    
    public String getScrumTeamsNameList() {
    	
    	List<ADM_Scrum_Team__c> teams = [Select Id, Name From ADM_Scrum_Team__c where Active__c = true order by Name];
    	
		

		String output = '';
		
		JSONGenerator jsonScrumTeamGenerator = JSON.createGenerator(true);
		
		jsonScrumTeamGenerator.writeStartArray();
		
		for (ADM_Scrum_Team__c t : teams) {
			
			jsonScrumTeamGenerator.writeStartObject(); 
			jsonScrumTeamGenerator.writeStringField('Id', t.Id);
			jsonScrumTeamGenerator.writeStringField('Name', t.Name);
		    jsonScrumTeamGenerator.writeStringField('label', t.Name);
		    jsonScrumTeamGenerator.writeEndObject();
		}
			

		jsonScrumTeamGenerator.writeEndArray();
		
		output = jsonScrumTeamGenerator.getAsString();
		
		
    	
    	return output; 
    	
    }
    
    /**
     * Gets the sprint that is associated to the specified ID
     */
    @RemoteAction
    public static ADM_Sprint__c getSprintById(Id sprintId) {
        /*
            Checked in GUS-Data if FLS is not there the fields won't display data on page and shows as blank.
        */
        List<ADM_Sprint__c> sprints = [select Id, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedBy.FirstName, Name, End_Date__c, Goals__c, Hours_in_a_work_day__c, Retrospective__c, Risks__c, Scrum_Team__r.Id, Scrum_Team__r.Name, Start_Date__c, Total_Workdays__c from ADM_Sprint__c where Id = :sprintId limit 1];
        if(sprints.isEmpty()) {
        	return null;
        } else {
        	return sprints.get(0);
        }
    }
    
     /**
     * Deletes the sprint corresponding to the ID from the database.
     * @returns Returns true if the deletion was successful. 
     */
    @RemoteAction
    public static Boolean deleteSprint(Id sprintId) {
    	
    	if(ADM_SchemaManager.isObjectDeletable('ADM_Sprint__c')){
    	   ADM_Sprint__c sprint = [select Id from ADM_Sprint__c where Id = :sprintId limit 1];
           
           if(sprint != null) {
        	   delete sprint;
        	}
        	
        	return true;
        }
        else{
            System.debug('Current user has no delete access to ADM_Sprint__c');
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Sprint__c');
        }
    }
    
    
     /**
     * Saves the specified sprint object.
     * Returns the saved sprint object.
     */
    @RemoteAction
    public static ADM_Sprint__c saveSprint(ADM_Sprint__c sprint) {
        if(ADM_SchemaManager.isObjectUpsertable('ADM_Sprint__c')){
        	if(sprint == null) {
        		return null;
        	}
        	upsert sprint;
        	sprint = [select Id, LastModifiedDate from ADM_Sprint__c where Id = :sprint.Id];
        	
        	return sprint;
        }
        else{
             System.debug('Current user has no upsert access to ADM_Sprint__c');
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Sprint__c');
        }
    }
    
}