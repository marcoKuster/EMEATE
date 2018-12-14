public with sharing class ADM_TeamSelectorController {
    public String currentSprintId { get; set; }
    public String teamMemberId { get; set; }
    public String message { get; set; }
    public List<ADM_Scrum_Team_Member__c> allocations { get; set; }
    public Map<String, String> teamSprintMap { get; set; }
    public User t { get; set;}
    private static final String MESSAGE_NO_RECORDS = 'No records to display';

    public ADM_TeamSelectorController() {
        try{
            teamMemberId = UserInfo.getUserId();
            allocations = new List<ADM_Scrum_Team_Member__c>();
            teamSprintMap = new Map<String, String>();
            message = '';
            t = [Select t.FirstName,t.SmallPhotoUrl From User t Where t.Id =: teamMemberId];
            allocations = [Select a.Id, a.RecordTypeId, a.Name, a.Scrum_Team__r.Name, a.Scrum_Team__c, a.Role__c, a.Member_Name__r.Name,
                           a.Member_Name__c, a.Allocation__c From ADM_Scrum_Team_Member__c a Where a.Member_Name__c =: teamMemberId And
                           a.Scrum_Team__r.Active__c = true ORDER BY a.Allocation__c Desc NULLS Last];
            
            if (allocations.size() > 1) {
                String sprintId;
                
                for (ADM_Scrum_Team_Member__c allocation : allocations) {
                    sprintId = ADM_SprintLocatorController.getCurrentSprintIdForTeam(allocation.Scrum_Team__c);
                    
                    if (sprintId != null) {
                        teamSprintMap.put(allocation.Scrum_Team__r.Name, sprintId);
                    
                        currentSprintId = sprintId;
                    }
                }
            }
            
            if (allocations.size() == 1) {
                currentSprintId = ADM_SprintLocatorController.getCurrentSprintIdForTeam(allocations[0].Scrum_Team__c, System.today());
                
                if (currentSprintId != null) {
                    teamSprintMap.put(allocations[0].Scrum_Team__r.Name, currentSprintId);
                }
            }
            
            if(allocations.isEmpty()) {
                message = MESSAGE_NO_RECORDS;
            }
        }
        catch(Exception e){
            System.debug('Error occured while fetching team allocation data : ' + e);
        }
    }

    public Integer getCurrentTeamCount() {
        List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null and Scrum_Team__r.Active__c = true order by Allocation__c DESC];
        return membership.size();
    }

    public Integer getCurrentSprintCount() {
        return teamSprintMap.size();
    }
    
    public String getAllTeamsLink() {
        //direct to list view for object
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
        return teamDescribe.getKeyPrefix();
    }

    public String getAllSprintsLink() {
        Schema.DescribeSObjectResult sprintDescribe = Schema.SObjectType.ADM_Sprint__c;
        return sprintDescribe.getKeyPrefix();
    }

    public static String getBaseUrl(){
        return System.Url.getSalesforceBaseUrl().toExternalForm();
    }
    
    public static Id getSprintListViewId() {
        List<ListView> sprintListView = ADM_SprintLocatorController.getSprintListView();

        return (sprintListView.size() > 0 ? sprintListView[0].Id : null);
    }
    
    public String sprintObjectWithNameSpace{ 
        get{
          String nameSpace = ADM_ConstantsSingleton.getInstance().getNameSpace();
          return nameSpace+'ADM_Sprint__c';
        }
        set;
       
    }
}