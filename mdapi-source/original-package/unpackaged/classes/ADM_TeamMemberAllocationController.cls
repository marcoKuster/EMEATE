public with sharing class ADM_TeamMemberAllocationController {
    public String teamMemberId { get; set; }
    public String message { get; set; }
    public List<ADM_Scrum_Team_Member__c> allocations { get; set; }
    public User t { get; set;}
    private static final String MESSAGE_INVALID_ID = 'A valid user ID value was not provided.';
    private static final String MESSAGE_NO_RECORDS = 'No records to display';
    
    
    public ADM_TeamMemberAllocationController() {
        teamMemberId = System.currentPageReference().getParameters().get('Id');
        allocations = new List<ADM_Scrum_Team_Member__c>();
        t = new User();
        
        if(teamMemberId == null || teamMemberId == '' || !ADM_TextUtils.isValidId(teamMemberId)) {            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, MESSAGE_INVALID_ID));
            message = MESSAGE_NO_RECORDS;
        } else { 
            message = '';
            t = [Select t.Name From User t Where t.Id =: teamMemberId];
            allocations = [Select a.Id, a.RecordTypeId, a.Name, a.Scrum_Team__r.Name, a.Scrum_Team__c, a.Role__c, a.Member_Name__r.Name, a.Member_Name__c, a.Allocation__c From ADM_Scrum_Team_Member__c a Where a.Member_Name__c =: teamMemberId And a.Scrum_Team__r.Active__c = true and a.RecordType.Name = 'Internal'];
            if(allocations.isEmpty()) {
            	message = MESSAGE_NO_RECORDS;
            }            
        }   
        
    }
}