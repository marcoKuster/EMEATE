@isTest
private class ADM_ProfileTeamAllocationControllerTest {

	private static String message = 'No records to display';
/*
@userstory:  a07B0000000F9LW
@testcaseID:  a1DB00000000qsX
@expected results: User is taken to the Team Member allocation and all allocations for that team member are shown, using the following columns: Team Member record, role, team and allocation
hierarchy: GUS.ScrumTeamMembers.User View Allocation link
*/
    static testMethod void testWithValidUserId() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
    	ADM_Scrum_Team_Member__c t = new ADM_Scrum_Team_Member__c();
    	User u = ADM_WorkUser.createTestUser();
    	t.Allocation__c = 1;
    	t.Member_Name__c = u.Id;
    	t.RecordTypeId = [Select Id From RecordType Where Name = 'Internal'].Id;
    	t.Scrum_Team__c = team.Id;
    	insert t;
    	System.currentPageReference().getParameters().put('sfdc.userId',t.Member_Name__c);
    	ADM_ProfileTeamAllocationController controller = new ADM_ProfileTeamAllocationController();
        System.assertEquals('',controller.message);
        System.assertEquals(false, Apexpages.hasMessages());
        System.assertEquals(1, controller.allocations.size(), '' + controller.allocations);
        System.assertEquals(t.Member_Name__c, controller.teamMemberId);        
    } 
/*
@userstory:  a07B0000000F9LW
@testcaseID:  a1DB00000000qsM
@expected results: User is taken to the Team Member allocation and "no records to display" is shown
hierarchy: GUS.ScrumTeamMembers.User View Allocation link
*/
    static testMethod void testWithValidUserIdNoMemberships() {
    	User u = ADM_WorkUser.createTestUser();
    	System.currentPageReference().getParameters().put('sfdc.userId',u.Id);
    	ADM_ProfileTeamAllocationController controller = new ADM_ProfileTeamAllocationController();
        System.assertEquals(message,controller.message);
        System.assertEquals(false, Apexpages.hasMessages());
        System.assertEquals(0, controller.allocations.size(), '' + controller.allocations);
        System.assertEquals(u.Id, controller.teamMemberId);        
    }
	
}