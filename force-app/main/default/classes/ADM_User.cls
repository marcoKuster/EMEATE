public with sharing class ADM_User {
	public static boolean getUserLaneScrollingPreference(){
        ADM_User_Preferences__c userPreference = getCurrentUserPreference();
        return userPreference.LaneScrolling__c;
    }

    public static void setUserLaneScrollingPreference(boolean value){
        ADM_User_Preferences__c userPreference = getCurrentUserPreference();
        userPreference.LaneScrolling__c = value;
        upsert userPreference;
    }

    public static void saveKanbanWorkCardPreferences(ADM_KanbanPreferences kanbanPreferences){
    	ADM_User_Preferences__c userPreference = getCurrentUserPreference();
    	userPreference.UseColorCoding__c = kanbanPreferences.getUseColorCoding();
		userPreference.ShowNumberOfDaysInColumn__c = kanbanPreferences.getShowNumberOfDaysInColumn();
		userPreference.ShowNumberOfTasks__c = kanbanPreferences.getShowNumberOfTasks();
		userPreference.ShowNumberOfPosts__c = kanbanPreferences.getShowNumberOfPosts();
		userPreference.ShowPriority__c = kanbanPreferences.getShowPriority();
		userPreference.ShowScheduledBuild__c = kanbanPreferences.getShowScheduledBuild();
		userPreference.ShowStoryPoints__c = kanbanPreferences.getShowStoryPoints();
		userPreference.ShowColoredSubjects__c = kanbanPreferences.getShowColoredSubjects();
		userPreference.ShowWorkID__c = kanbanPreferences.getShowWorkID();
		userPreference.ShowRecordTypeIcon__c = kanbanPreferences.getShowRecordTypeIcon();
		userPreference.ShowQE__c = kanbanPreferences.getShowQE();

		upsert userPreference;
    }

    public static void setKanbanWorkCardPreferences(ADM_KanbanPreferences kanbanPreferences){
    	ADM_User_Preferences__c userPreference = getCurrentUserPreference();
    	kanbanPreferences.setUseColorCoding(userPreference.UseColorCoding__c);
		kanbanPreferences.setShowNumberOfDaysInColumn(userPreference.ShowNumberOfDaysInColumn__c);
		kanbanPreferences.setShowNumberOfTasks(userPreference.ShowNumberOfTasks__c);
		kanbanPreferences.setShowNumberOfPosts(userPreference.ShowNumberOfPosts__c);
		kanbanPreferences.setShowPriority(userPreference.ShowPriority__c);
		kanbanPreferences.setShowScheduledBuild(userPreference.ShowScheduledBuild__c);
		kanbanPreferences.setShowStoryPoints(userPreference.ShowStoryPoints__c);
		kanbanPreferences.setShowColoredSubjects(userPreference.ShowColoredSubjects__c);
		kanbanPreferences.setShowWorkID(userPreference.ShowWorkID__c);
		kanbanPreferences.setShowRecordTypeIcon(userPreference.ShowRecordTypeIcon__c); 
		kanbanPreferences.setShowQE(userPreference.ShowQE__c); 
    }

    public static ADM_User_Preferences__c getCurrentUserPreference(){
    	return ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
    }

    public static boolean isCurrenUserSysAdmin(){
    	Profile profile = [SELECT Name From Profile WHERE Id = :UserInfo.getProfileId()];
        if ( profile.Name == 'System Administrator' ) {
        	return true;
        }
        else{
        	return false;
        }
    }
    // Roster record cloud update privilege only available for Roster_TPM and Roster_Finance group members
    public static boolean currentUserHasRosterCloudChangePrivilege(){
        Set<String> assigneeIds = getPermsetAssignees();
        return assigneeIds.contains(UserInfo.getUserId());
    }
    
    private static Set<String> getPermsetAssignees(){
        Set<String> assigneeIds = new Set<String>();
        if(Test.isRunningTest()){
            assigneeIds.add(UserInfo.getUserId());//Adding current user as Permset might not be added when running test
        }
        else{
        List<PermissionSetAssignment> permSetAssignees = [select AssigneeId from PermissionSetAssignment where permissionsetid in
                                                         (select id  from permissionset where name in ('Cloud_Technical_Program_Manager', 'Headcount_Finance'))];
            
        for(PermissionSetAssignment assignee: permSetAssignees){
            assigneeIds.add(assignee.AssigneeId);
        } 
        }
        
        return assigneeIds;
        
    }
}