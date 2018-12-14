public with sharing class ADM_SprintLocatorController {

    public PageReference goToCurrentSprint() {
        return goToSprint(System.today());
    }    
    
    
    public PageReference goToSprint(Date value) {
        
            PageReference pr = Page.ADM_SprintDetail_VirtualWall;
            Id currentSprintId = null;
            //determine users current sprint based on their scrum team membership
            List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null order by Allocation__c DESC limit 1];
            if(membership != null && membership.size() == 1) {
                Id scrumTeamId = membership.get(0).Scrum_Team__c;
                
                currentSprintId = ADM_SprintLocatorController.getCurrentSprintIdForTeam(scrumTeamId, value);
            }    
                
            //if a sprint was located direct to the user to it otherwise direct them to a list view
            
            if(currentSprintId != null) {
                pr.getParameters().put('id', currentSprintId);
            } else {
                //direct to list view for object
                pr = new PageReference('/' + ADM_SprintLocatorController.getSprintObjPrefix());
            }    
                
            return pr;
    }

    public static Id getCurrentSprintIdForTeam(Id scrumTeamId) {
        Id currentSprintId = ADM_SprintLocatorController.getCurrentSprintIdForTeam(scrumTeamId, System.today());

        if (currentSprintId == null) {
            List<ADM_Sprint__c> teamSprint = [select id, End_Date__c from ADM_Sprint__c where Scrum_Team__c =:scrumTeamId order by End_Date__c DESC, CreatedDate DESC limit 1];

            if(!teamSprint.isEmpty()) {
                currentSprintId = teamSprint.get(0).Id;
            }
        }

        return currentSprintId;
    }

    public static Id getCurrentSprintIdForTeam(Id scrumTeamId, Date value) {
        Id currentSprintId = null;
        //determine the correct sprint based on the team ID and current date

    String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(nameSpace+'ADM_Sprint__c');
        String[] params = new String[]{'Id','Scrum_Team__c','Start_Date__c','End_Date__c'};
        Map<String,Schema.SObjectField> mapToCheck = new Map<String,Schema.SObjectField>();
        for ( String p : params ){
            mapToCheck.put( nameSpace+p, targetType.getDescribe().fields.getMap().get(p));
        }

        List<ADM_Sprint__c> sprints = [select id from ADM_Sprint__c where Scrum_Team__c =:scrumTeamId and Start_Date__c <=: value and End_Date__c >=: value order by CreatedDate DESC limit 1];
        if(sprints != null && sprints.size() == 1) {
           currentSprintId = sprints.get(0).Id; 
        } else {
            
            //if no current sprint, then get the last sprint available. Don't show sprints older than 14 days
            Date cutoffDate = value.addDays(-14);
            List<ADM_Sprint__c> previousSprints = [select id, End_Date__c from ADM_Sprint__c where Scrum_Team__c =:scrumTeamId and End_Date__c <=: value and End_Date__c >= :cutoffDate order by End_Date__c DESC, CreatedDate DESC limit 1];
            if(!previousSprints.isEmpty()) {
                currentSprintId = previousSprints.get(0).Id;
            }
        }

        return currentSprintId;
    }

    public static String getSprintObjPrefix() {
        Schema.DescribeSObjectResult sprintDescribe = Schema.SObjectType.ADM_Sprint__c; 

        return sprintDescribe.getKeyPrefix();
    }
    
    public static List<ListView> getSprintListView() {
        String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
        String sobjectName = nameSpacePrefix+'ADM_Sprint__c';
        List<ListView> listview = new List<ListView>();

        listview = [SELECT Id, Name FROM ListView WHERE SobjectType =: sobjectName and Name IN('All', 'Recently Viewed') ORDER BY Name ASC LIMIT 1];

        if (listview.isEmpty()) {
            listview = [SELECT Id, Name, CreatedDate FROM ListView WHERE SobjectType =: sobjectName ORDER BY CreatedDate ASC LIMIT 1];
        }
    
        return listview;
    }
}