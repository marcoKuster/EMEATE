public with sharing class ADM_ScrumTeamUtils {
    public void setExternalId(ADM_Scrum_Team__c[] teams) {
        for(ADM_Scrum_Team__c team : teams) {
            team.External_Name__c = team.Name;
        }
    }
    
    public void validateStoryPoints(ADM_Scrum_Team__c[] teams) { 
        for(ADM_Scrum_Team__c team : teams) {
            if(ADM_TextUtils.isBlank(team.Story_Point_Scale__c)) {              
            } else {
                if(team.Story_Point_Scale__c.replaceAll(',','').replaceAll('[0-9]','').length() > 0) {
                    team.addError('Team story point scales can only contain digits and commas');
                }
            }
        }
    }
        
    /**
     * Creates the public groups for the specified teams
     */
    public static void createPublicGroupsForTeams(ADM_Scrum_Team__c[] teams) {
        List<ADM_Scrum_Team_Cache__c> scrumteamCaches = ADM_ScrumteamCacheUtils.createAndInsertNewTeamCaches(teams);
        
        List<String> scrumteamCachesIds = ADM_ScrumteamCacheUtils.pluckId(scrumteamCaches);
        if(!scrumteamCachesIds.isEmpty()) {
            asynchronouslyCreateGroups(scrumteamCachesIds);
        }
    }
    
    /**
     * Deletes the public groups for the specified teams
     */
    public static void deletePublicGroupsForTeams(ADM_Scrum_Team__c[] teams) {
        List<ADM_Scrum_Team_Cache__c> scrumteamCaches = ADM_ScrumteamCacheUtils.createAndInsertDeleteTeamCaches(teams);
        List<String> scrumteamCachesIds = ADM_ScrumteamCacheUtils.pluckId(scrumteamCaches);
        if(!scrumteamCachesIds.isEmpty()) {
            asynchronouslyDeleteGroups(scrumteamCachesIds);
        }
    }
    
    private static List<String> groupIdsFromScrumteams(List<ADM_Scrum_Team__c> scrumteams) {
        List<String> ids = new List<String>();
        if(!scrumteams.isEmpty()) {
            for(ADM_Scrum_Team__c scrumteam : scrumteams) {
                ids.add(scrumteam.Team_Email_Group_ID__c);
            }
        }
        
        return ids;
    }
    
    @Future
    private static void asynchronouslyDeleteGroups(List<String> scrumteamCachesIds) {
        List<Group> groups = new List<Group>();
        List<ADM_Scrum_Team_Cache__c> scrumteamCaches = [select Name__c, Type__c, ScrumteamOrScrumteamMember__c from ADM_Scrum_Team_Cache__c where Id in : scrumteamCachesIds];
        List<ADM_Scrum_Team__c> scrumteams = [select Id, Name, Team_Email_Group_ID__c from ADM_Scrum_Team__c where Id in : ADM_ScrumteamCacheUtils.idsFromScrumTeamField(scrumteamCaches) all rows];
        
        Integer loopCount = 0;
        
        if(!scrumteams.isEmpty()) {
            groups = [select Id from Group where Id in : groupIdsFromScrumteams(scrumteams)];
            
            Database.Deleteresult[] results = Database.delete(groups,false);
            List<Database.DeleteResult> failedDeleteResults = new List<Database.DeleteResult>();
            for(Database.DeleteResult result : results) {
                if(!result.isSuccess()) {
                    
                    failedDeleteResults.add(result);
                }
                loopCount++;
            }
            ADM_ExceptionHandler.saveExceptions(failedDeleteResults, null, 'Error occurred while deleting group', null, true);
        }
    }
    
    @Future
    private static void asynchronouslyCreateGroups(List<String> scrumteamCachesIds) {
        try{
            List<Group> groups = new List<Group>();
            List<ADM_Scrum_Team_Cache__c> scrumteamCaches = [select Name__c, Type__c, ScrumteamOrScrumteamMember__c from ADM_Scrum_Team_Cache__c where Id in : scrumteamCachesIds];
            if(scrumteamCaches.isEmpty()) {
                return;
            }
            
            List<String> ids = ADM_ScrumteamCacheUtils.idsFromScrumTeamField(scrumteamCaches);
            Map<Id,ADM_Scrum_Team__c> scrumteams = new Map<Id,ADM_Scrum_Team__c>([select Id, Name, Team_Email_Group_ID__c from ADM_Scrum_Team__c where Id in : ids]);
            
            for(ADM_Scrum_Team_Cache__c scrumteamCache : scrumteamCaches) {
                //Public groups only allow a group name to contain 40 characters. Here we create a group to be same as the team cache name.
                //So we trim it to 40 characters if it is more than 40 to avoid an exception.
                String groupName = scrumteamCache.Name__c;
                if(groupName.length() > 40){
                    groupName = scrumteamCache.Name__c.substring(0,40);
                }
                groups.add(new Group(Name = groupName, Type = scrumteamCache.Type__c));
            }
            
            Database.Saveresult[] results = Database.insert(groups,false);
            List<Database.SaveResult> failedSaveResults = new List<Database.SaveResult>();
            for(Integer index = 0; index < results.size(); index++) {
                Database.Saveresult result = results.get(index);
                ADM_Scrum_Team_Cache__c scrumteamCache = scrumteamCaches.get(index);
                ADM_Scrum_Team__c scrumteam = scrumteams.get(scrumteamCache.ScrumteamOrScrumteamMember__c);
                
                if(!result.isSuccess()) {
                    
                    scrumteams.remove(scrumteam.Id);
                    failedSaveResults.add(result);
                } else {
                    if(scrumteam != null) {
                        scrumteam.Team_Email_Group_ID__c = result.getId();
                        scrumteams.put(scrumteam.Id, scrumteam);                        
                    }
                }
            }
            ADM_ExceptionHandler.saveExceptions(failedSaveResults, null, 'Error occurred while inserting groups', null,true);
            
            if(!scrumteams.isEmpty()) {
                Database.update(scrumteams.values(), false);
            }
        }
        catch(Exception exp){
            ADM_ExceptionHandler.saveException(exp, 'Error occurred while inserting group by Future method');
        }
    }
}