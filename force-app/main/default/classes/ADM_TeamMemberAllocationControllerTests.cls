/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ADM_TeamMemberAllocationControllerTests {
	private static String error = 'a Valid user ID value was not provied.';
	private static String message = 'No records to display';
	
   /*
    @testcaseID  a1DB00000000qsR
    @userstory  a0790000000DQDtAAO
    @hierarchy  GUS.ScrumforceToGUS.ScrumTeamMembers.User View Allocation link
    @expected results  User is taken to the Team Member allocation and "no records to display" is shown
    @author Alexis Williams
    */	

    static testMethod void testWithInvalidUserIds() {
        System.currentPageReference().getParameters().put('ids','1');
        ADM_TeamMemberAllocationController controller = new ADM_TeamMemberAllocationController();
        System.assertEquals(message,controller.message);
        System.assertEquals(true, Apexpages.hasMessages());
    }
    
    /*
    @testcaseID  a1DB00000000qsX
    @userstory  a0790000000DQDtAAO
    @hierarchy  GUS.ScrumforceToGUS.ScrumTeamMembers.User View Allocation link
    @expected results  User is taken to the Team Member allocation and all allocations for that team member are shown, using the following columns: Team Member record, role, team and allocation
    @author Alexis Williams
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
    	System.currentPageReference().getParameters().put('Id',t.Member_Name__c);
    	ADM_TeamMemberAllocationController controller = new ADM_TeamMemberAllocationController();
        System.assertEquals('',controller.message);
        System.assertEquals(false, Apexpages.hasMessages());
        System.assertEquals(1, controller.allocations.size(), '' + controller.allocations);
        System.assertEquals(t.Member_Name__c, controller.teamMemberId);        
    } 
    
   /*
    @testcaseID  a1DB00000000VAl
    @userstory  a0790000000DQDtAAO
    @hierarchy  GUS.ScrumforceToGUS.ScrumTeamMembers.User View Allocation link
    @expected results  User is taken to the Team Member allocation and "no records to display" is shown
    @author Alexis Williams
    */

    static testMethod void testWithValidUserIdNoMemberships() {
    	User u = ADM_WorkUser.createTestUser();
    	System.currentPageReference().getParameters().put('Id',u.Id);
    	ADM_TeamMemberAllocationController controller = new ADM_TeamMemberAllocationController();
        System.assertEquals(message,controller.message);
        System.assertEquals(false, Apexpages.hasMessages());
        System.assertEquals(0, controller.allocations.size(), '' + controller.allocations);
        System.assertEquals(u.Id, controller.teamMemberId);        
    }
}