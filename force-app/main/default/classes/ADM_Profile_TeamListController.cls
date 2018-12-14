public class ADM_Profile_TeamListController {

    @AuraEnabled
    public static List<ADM_Scrum_Team_Member__c> getScrumTeams( Id userId ) {
        List<ADM_Scrum_Team_Member__c> team_member = [SELECT Scrum_Team__r.Name,Scrum_Team__r.Active__c, Allocation__c, Role__c FROM ADM_Scrum_Team_Member__c WHERE Member_Name__c =: userId AND Scrum_Team__r.Active__c = true ORDER BY Allocation__c DESC ];
        return team_member;
    }

}