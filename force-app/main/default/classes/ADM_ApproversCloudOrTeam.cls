public class ADM_ApproversCloudOrTeam {
    /*
     * Takes a list of form: <user ID>:<cloud__c ID>:<scrum_team__c ID> 
     * and returns a list of form: <user ID>:<cloud__c Name> Cloud OR <user ID>:<scrum_team__c Name> Team
     * If both Cloud and Team IDs are given, only Cloud is used.
     */
    @InvocableMethod
    public static List<List<String>> ADM_ApproversCloudOrTeam(List<List<String>> cloudTeamList) {
        Map<Id, ADM_Cloud__c> clouds = new Map<Id, ADM_Cloud__c>();
        Map<Id, ADM_Scrum_Team__c> teams = new Map<Id, ADM_Scrum_Team__c>();
        List<List<String>> returnList = new List<List<String>>();
		
        for (List<String> aCloudTeamList : cloudTeamList) {
        
            for (String key : aCloudTeamList) {
                String cloudId = key.substringAfter(':').substringBefore(':');
                String teamId = key.substringAfterLast(':');
                if (cloudId != null && cloudId.length() > 0) {
                    clouds.put((Id)cloudId, null);
                } else if (teamId != null && teamId.length() > 0) {
                    teams.put((Id)teamId, null);                
                }
                /* DEBUG OFF */ System.Debug('ADM_ApproversCloudOrTeam: cloudId=' + cloudId + ' teamId=' + teamId); /* DEBUG */
            }
        }
        if (clouds.size() > 0) {
            try {
                clouds = new Map<Id, ADM_Cloud__c>([SELECT Id, Name from ADM_Cloud__c where Id =: clouds.keySet()]);
            } catch (Exception e) {
                System.Debug('ADM_ApproversCloudOrTeam: Exception accessing Cloud records: ' + e);
            }
        }
        if (teams.size() > 0) {
            try {
                teams = new Map<Id, ADM_Scrum_Team__c>([SELECT Id, Name from ADM_Scrum_Team__c where Id =: teams.keySet()]);
            } catch (Exception e) {
                System.Debug('ADM_ApproversCloudOrTeam: Exception accessing Team records: ' + e);
            }
        }
        for (List<String> aCloudTeamList : cloudTeamList) {
        
            List<String> aReturnList = new List<String>();
            for (String key : aCloudTeamList) {
                ID userId = key.substringBefore(':');			// userId will always be a valid ID
                String cloudId = key.substringAfter(':').substringBefore(':');
                if (cloudId != null && cloudId.length() > 0) {
                    ADM_Cloud__c cloud = clouds.get(cloudId);
                    if (cloud != null) {
                        aReturnList.add(userId + ':' + cloud.Name + ' Cloud');
                    }
                } else {
                    String teamId = key.substringAfterLast(':');
                    if (teamId != null && teamId.length() > 0) {
                        ADM_Scrum_Team__c team = teams.get(teamId);
                        if (team != null) {
                            aReturnList.add(userId + ':' + team.Name + ' Team');
                        }
                    }  
                }
            }
            returnList.add(aReturnList);
        }
    	return returnList;
    }
}