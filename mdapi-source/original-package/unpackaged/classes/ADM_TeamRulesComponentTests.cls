@isTest
    /**
    * @testcaseID a1DB00000000phk
    * @userstoryID a07B0000000FeoW
    * @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Assignments and Themes.Assignment Rules List
    * @Expected Results The active assignment rules linked to Product tags should show on the Assignments and Themes tab of the Team page
    * @Author: Chris Copek
    */
private class ADM_TeamRulesComponentTests {

    static testMethod void testActiveTagAssignmentsAreDisplayed() {
    	ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = rule.Scrum_Team_Assignment__c;
        tag.Name = 'Test Name 123987675';
    	Database.insert(tag);
    	ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
    	tagAssignment.Product_Tag__c = tag.Id;
    	tagAssignment.Assignment_Rule__c = rule.Id;
    	tagAssignment.Record_Type__c = 'Bug';
    	Database.insert(tagAssignment);
        ADM_TeamRulesController tr = new ADM_TeamRulesController();
        tr.team = ADM_ScrumTeam.get('id', new List<String>{rule.Scrum_Team_Assignment__c}).get(0);
        List<ADM_Tag_Assignment__c> tagAssignments = tr.getTagAssignments();
        System.assert(tagAssignments!= null);
        System.assertEquals(1, tagAssignments.size());
    }
    
    /**
    * @testcaseID a1DB00000000puh
    * @userstoryID a07B0000000E1pz
    * @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Assignments and Themes.Assignment Rules List
    * @Expected Results User should not see tag assignment with an inactive product tag on Assignments and Themes section in the team's page
    * @Author: James Hatton
    */

    static testMethod void testInactiveTagAssignmentsAreNotDisplayed() {
    	ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
    	
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = rule.Scrum_Team_Assignment__c;
        tag.Name = 'Test Name 123987675';
        tag.Active__c = false;
    	Database.insert(tag);
    	ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
    	tagAssignment.Product_Tag__c = tag.Id;
    	tagAssignment.Assignment_Rule__c = rule.Id;
    	tagAssignment.Record_Type__c = 'Bug';
    	Database.insert(tagAssignment);

        tag.Active__c = false;
		update tag;
		    	
        ADM_TeamRulesController tr = new ADM_TeamRulesController();
        tr.team = ADM_ScrumTeam.get('id', new List<String>{rule.Scrum_Team_Assignment__c}).get(0);
        List<ADM_Tag_Assignment__c> tagAssignments = tr.getTagAssignments();
        System.assertEquals(0, tagAssignments.size());
    }
    	/*
	@testcaseID a1DB00000000rsb
	@userstoryID a07B0000000EaYV
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Assignments and Themes.New Assignment Rule
	@expected results When user clicks New Product Tag, the new product tag page appears. Once the AR is saved, user is taken back to Team
	@author: jhatton
	*/
	

    static testMethod void testNewProductTagButton() {
    	ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        ADM_TeamRulesController tr = new ADM_TeamRulesController();
        tr.team = ADM_ScrumTeam.get('id', new List<String>{rule.Scrum_Team_Assignment__c}).get(0);
        PageReference pr = tr.redirectToNewProductTag();
        System.assert(pr != null);
        System.assertEquals(rule.Scrum_Team_Assignment__c, pr.getParameters().get('Team__c'));
    }
    
    /**
    * @testcaseID a1DB00000002MQr
    * @userstoryID a07B0000000N1AFIA0
    * @Hierarchy GUS.ScrumforceToGUS.Product Tags.New Product tag button
    * @Expected Results as a team member, a team member with GUS profile can create new product tag
    */
    static testMethod void testCanCreateProductTagWhenInTeam() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        //create a user that is a member of the team
        User userInTeam = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership = new ADM_Scrum_Team_Member__c();
        membership.Member_Name__c = userInTeam.Id;
        membership.Scrum_Team__c = team.Id;
        insert membership;
        
        System.runAs(userInTeam) {
            ADM_TeamRulesController tr = new ADM_TeamRulesController();
            tr.team = team;
            Boolean actual = tr.getCanCreateProductTag();
            System.assertEquals(true, actual, 'Expected the user to be able to create a new product tag because they are part of the team.');
        }
    }
    
    /**
    * @testcaseID a1DB00000002MVt
    * @userstoryID a07B0000000N1AFIA0
    * @Hierarchy GUS.ScrumforceToGUS.Product Tags.New Product tag button
    * @Expected Results as a team member of another team, the Create new product tag button is not visible
    */
    static testMethod void testCannotCreateProductTagWhenNotInTeam() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        //create a user that is NOT a member of the team
        User user = ADM_WorkUser.createTestUser();
        
        System.runAs(user) {
            ADM_TeamRulesController tr = new ADM_TeamRulesController();
            tr.team = team;
            Boolean actual = tr.getCanCreateProductTag();
            System.assertEquals(false, actual, 'Expected the user to not be able to create a new product tag because they are not part of the team.');
        }
    }
}