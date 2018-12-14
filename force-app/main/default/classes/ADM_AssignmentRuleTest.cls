public class ADM_AssignmentRuleTest {

    @IsTest
    public static ADM_Assignment_Rule__c setupRule() {
        ADM_Assignment_Rule__c rule = populateRule();
         
        insert rule;
        return rule;
    }
     
    @IsTest
    public static ADM_Assignment_Rule__c populateRule() {
    	return populateRule(ADM_Work.BUG_RECORD_TYPE_NAME);
    }
	
    private static ADM_Assignment_Rule__c populateRule(String workRecordType) {
        
        User user1 = ADM_WorkUser.createTestUser();
        User user2 = ADM_WorkUser.createTestUser();

        //create rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = user1.id;
        rule.Product_Owner__c = user2.id;
        rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam(String.valueOf(Math.random())).id;
        rule.QA_Assignment__c = user2.id;
        rule.Tech_Writer_Assignment__c = user2.id;
        rule.UE_Engineer__c = user2.id;
        rule.Systest_Assignment__c = user2.id;
        rule.Senior_Management_POC_Assignment__c = user2.id;
        rule.Additional_Emails__c = 'gusteam@salesforce.com';
		
        return rule;
    }
     
	private static ADM_Assignment_Rule__c populateRule(ADM_Assignment_Rule__c cloneRule) {
        //create rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = cloneRule.Assignee_Assignment__c;
        rule.Product_Owner__c = cloneRule.Product_Owner__c;
        rule.Scrum_Team_Assignment__c = cloneRule.Scrum_Team_Assignment__c;
        rule.QA_Assignment__c = cloneRule.QA_Assignment__c;
        rule.Tech_Writer_Assignment__c = cloneRule.Tech_Writer_Assignment__c;
        rule.UE_Engineer__c = cloneRule.UE_Engineer__c;
        rule.Systest_Assignment__c = cloneRule.Systest_Assignment__c;
        rule.Senior_Management_POC_Assignment__c = cloneRule.Senior_Management_POC_Assignment__c;
        rule.Additional_Emails__c = cloneRule.Additional_Emails__c;
     
    	return rule;
    }
     
	
	     
    @IsTest
    public static ADM_Assignment_Rule__c setupRuleInvestigation() {
        User user1 = ADM_WorkUser.createTestUser();
        User user2 = ADM_WorkUser.createTestUser();
         
        //create rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = user1.id;
        rule.Product_Owner__c = user2.id;
        rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam(String.valueOf(Math.random())).id;
        rule.QA_Assignment__c = user2.id;
        rule.Tech_Writer_Assignment__c = user2.id;
        rule.UE_Engineer__c = user2.id;
        rule.Systest_Assignment__c = user2.id;
        rule.Senior_Management_POC_Assignment__c = user2.id;
        rule.Exception_Request_POC__c = user2.Id;
        rule.Sev_1_Assignee__c = user2.id;
        rule.Sev_2_Assignee__c = user2.id;
        rule.Sev_3_Assignee__c = user2.id;
        rule.Sev_4_Assignee__c = user2.id;
         
        insert rule;
        return rule;		        
    }

	/*
	@testcaseID a1DB00000001S2k
	@userstory a07B0000000FeoMIAS
	@Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Assignment Rule from AR page
	@Expected Results An error message stating that a duplicate value exists shows on the assignment rule page
	*/
    
  	/**
  	 * @expectedResults  Adding a new Assignment Rule with matching scrum team and assignment rules as existing rule causes failure
	 * @author ccopek
     */
	static testMethod void testDuplicateAssignmentRule() {
		//setup rule
        ADM_Assignment_Rule__c rule = populateRule();
        
		insert rule;
		
		// setup another rule the same way, and try to insert
		ADM_Assignment_Rule__c rule2 = populateRule(rule);

		String duplicateId = ADM_AssignmentRule.checkForDuplicateAssignmentRule(rule2);
		System.assert(duplicateId.equals(rule.ID), 'Should have been returned the first rule as a duplicate.');		
		
		// Now set the new rule inactive, and verify it can be inserted.
		rule2.Inactive__c = true;
		duplicateId = ADM_AssignmentRule.checkForDuplicateAssignmentRule(rule2);
		System.assert(duplicateId == null, 'Should have received an indication that the inactive rule is not a duplicate');		
		
		// Update the first assignment rule to be inactive.
		rule.Inactive__c = true;
		update rule;
		
		// Now try to add another rule with same parameters and active.  Should be able to insert it.
		ADM_Assignment_Rule__c rule3 = populateRule(rule);
		rule3.Inactive__c = false;
		duplicateId = ADM_AssignmentRule.checkForDuplicateAssignmentRule(rule3);
		System.assert(duplicateId == null, 'Should have received an indication that the rule is not a duplicate');		
	}
}