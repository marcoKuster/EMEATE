public with sharing class ADM_TeamLocatorController {

    ADM_ConstantsSingleton singletonConstants = ADM_ConstantsSingleton.getInstance();
    
    private id getCurrentTeamId() {
        List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null and Scrum_Team__r.Active__c = true order by Allocation__c DESC];
        if(membership != null && membership.size() == 1) {
            return membership.get(0).Scrum_Team__c;
        } else {
            return null;
        }
    }
    
    private Integer getCurrentTeamCount() {
        List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null and Scrum_Team__r.Active__c = true order by Allocation__c DESC];
        return membership.size();
    }

    public PageReference goToCurrentTeam() {
            PageReference pr = Page.ADM_ScrumTeamDetail;
            Integer currentTeamCount = getCurrentTeamCount();
            Id currentTeamId = getCurrentTeamId();
            
            if (currentTeamId != null && currentTeamCount == 1) {
                // go to the one team
                boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
                if(isSFXPagePreferred){
                    pr = new PageReference('/' + currentTeamId);
                }
                else{
                pr.getParameters().put('id', currentTeamId);
                }
                return pr;
            } else if (currentTeamCount > 0) {
                // show team selector component
                return null;
            } else {
                // team listview
                Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
                String objectPrefix = teamDescribe.getKeyPrefix();
                pr = new PageReference('/' + objectPrefix);
                return pr;
            }
    }    

    public PageReference goToCurrentWall() {
            PageReference pr = Page.ADM_Wall;
            Integer currentTeamCount = getCurrentTeamCount();
            Id currentTeamId = getCurrentTeamId();
            
            if (currentTeamId != null && currentTeamCount == 1) {
                // go to the unified wall
                pr.getParameters().put('teamid', currentTeamId);
                return pr;
            } else {
                // show team selector component
                return null;
            }
    } 
    
    public PageReference goToCurrentKanbanBoard() {
            PageReference pr = Page.ADM_KanbanSplash;
            Integer currentTeamCount = getCurrentTeamCount();
            Id currentTeamId = getCurrentTeamId();
            
            if (currentTeamId != null && currentTeamCount == 1) {
                // go to the kanban board's splash screen. 
                pr.getParameters().put('teamid', currentTeamId);
                return pr;
            } else {
                // show team selector component
                return null;
            }
    } 
    
    public String nameSpace{
        get{
          return singletonConstants.getNameSpace();
        }
        set;
       
    }

}