public with sharing class ADM_ScrumTeamMembersOutOfOffice {

    public ADM_ScrumTeamMembersOutOfOffice(ApexPages.StandardController controller) {
        
    }
    
    public ADM_ScrumTeamMembersOutOfOffice() {
        
    }
    
    private String scrumTeamId { 
    	get {
    		if(scrumTeamId == null) scrumTeamId = System.currentPageReference().getParameters().get('id');
    		return scrumTeamId;
    	}
    	set;
    }
    
    
    
    public List<ADM_Time_Off_Log__c> teamMembersOutOfOffice {
    	get {
    		teamMembersOutOfOffice = findTeamMembersOutOfOfficeInformation(scrumTeamId);
    		if(teamMembersOutOfOffice.isEmpty()) Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO,'No scrum team members have any upcoming time off scheduled.'));
    		return teamMembersOutOfOffice;
    	}
    	set;
    }
    
    @AuraEnabled
    public static List<ADM_Time_Off_Log__c>  getTeamMembersOutOfOfficeList(String recordId) {
      List<ADM_Time_Off_Log__c> timeOffLogs = findTeamMembersOutOfOfficeInformation(recordId);
      return timeOffLogs;
        
    }
    
    
    private static List<ADM_Time_Off_Log__c> findTeamMembersOutOfOfficeInformation(String teamId){
        List<ADM_Time_Off_Log__c> oooLogs = new List<ADM_Time_Off_Log__c>();
        List<Id> teamMemberIds = new List<Id>();
        for (ADM_Scrum_Team_Member__c teamMemberId : [select Member_Name__c from ADM_Scrum_Team_Member__c where Scrum_Team__c = : teamId]) {
            teamMemberIds.add(teamMemberId.Member_Name__c);
        }
        oooLogs = [
            select RecordType.Name, Id,User__r.Name, User__r.Id, Start_Date__c, End_Date__c, Allocation__c, Description__c, Approved__c 
            from ADM_Time_Off_Log__c 
            where User__r.Id in : teamMemberIds    		 
            and End_Date__c >= : System.today()
            and (RecordType.Name = 'Out of Office' or (RecordType.Name = 'PTOn (Paid Time On)' and Approved__c = true))
            and User__r.Id != null
            order by Start_Date__c asc];
        
        return oooLogs;
    }
    
}