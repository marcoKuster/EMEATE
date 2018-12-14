@isTest
private class ADM_TeamSelectorControllerTest {

	private static String message = 'No records to display';
/*
@userstory:  a07B0000000yiqiIAA
@testcaseID:  
@expected results: 
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
    	System.RunAs(u) {
	    	ADM_TeamSelectorController controller = new ADM_TeamSelectorController();
	        System.assertEquals('',controller.message);
	        System.assertEquals(false, Apexpages.hasMessages());
	        System.assertEquals(1, controller.allocations.size(), '' + controller.allocations);
	        System.assertEquals(t.Member_Name__c, controller.teamMemberId);        
        }
    } 
/*
@userstory:  a07B0000000yiqiIAA
@testcaseID:  
@expected results: 
*/
    static testMethod void testWithValidUserIdNoMemberships() {
    	User u = ADM_WorkUser.createTestUser();
    	System.RunAs(u) {
	    	ADM_TeamSelectorController controller = new ADM_TeamSelectorController();
	        System.assertEquals(message,controller.message);
	        System.assertEquals(false, Apexpages.hasMessages());
	        System.assertEquals(0, controller.allocations.size(), '' + controller.allocations);
	        System.assertEquals(u.Id, controller.teamMemberId);        
		}
    }


    @isTest
    public static void getCurrentTeamCountTest(){
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Scrum_Team_Member__c t = new ADM_Scrum_Team_Member__c();
        User u = ADM_WorkUser.createTestUser();
        t.Allocation__c = 1;
        t.Member_Name__c = u.Id;
        t.RecordTypeId = [Select Id From RecordType Where Name = 'Internal'].Id;
        t.Scrum_Team__c = team.Id;
        insert t;
        System.RunAs(u) {
            ADM_TeamSelectorController controller = new ADM_TeamSelectorController();
            Integer c = controller.getCurrentTeamCount(); 
            String link = controller.getAllTeamsLink();
            System.assertEquals(c,1);
        }
    } 

}