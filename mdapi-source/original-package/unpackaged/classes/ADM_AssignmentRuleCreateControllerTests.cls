@IsTest
private class ADM_AssignmentRuleCreateControllerTests {
    
    static testMethod void testSaveRule() {
        //setup some test data
        ADM_Assignment_Rule__c rule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        System.assert(rule.id != null, 'Error setting up test data.  Assignment Rule was not inserted');
        ADM_Scrum_Team__c team = [select id, Name from ADM_Scrum_Team__c where id =:rule.Scrum_Team_Assignment__c];
        System.assert(team.id != null, 'Error setting up test data.  Scrum Team was not inserted');
        ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        System.assert(tag.id != null, 'Error setting up test data.  Product Tag was not inserted');
        //relate the product tag and the assignment rule for Bugs
        ADM_Tag_Assignment__c bugRule = new ADM_Tag_Assignment__c();
        bugRule.record_type__c = 'Bug';
        bugRule.Product_Tag__c = tag.id;
        bugRule.Assignment_Rule__c = rule.id;
        insert bugRule;
        
        //this controller is used exclusively in Lightning Experience.  To be backwards compatible with the design used
        //in Salesforce Classic we expect a new rule to be inserted and the old one to be de-activated
        
        ADM_Assignment_Rule__c newRule = ADM_AssignmentRuleCreateController.saveRule(tag.id, 'Bug', rule);
        System.assert(newRule.id != null);
        System.assert(rule.id != newRule.id, 'Expected a new rule to be inserted, but newRule and rule variables have the same id.');
        System.assertEquals(rule.Assignee_Assignment__c, newRule.Assignee_Assignment__c);
        //verify a new tag assignment was created to relate the new assignment rule to the product tag for the correct record type
        List<ADM_Tag_Assignment__c> newTagAssignments = [select id, record_type__c, Assignment_Rule__c, product_tag__c from ADM_Tag_Assignment__c where Assignment_Rule__c =:newRule.id];
        System.assert(newTagAssignments != null);
        System.assertEquals(1, newTagAssignments.size());
        ADM_Tag_Assignment__c newTagAssignment = newTagAssignments.get(0);
        System.assertEquals('Bug', newTagAssignment.Record_Type__c);
        System.assertEquals(tag.id, newTagAssignment.Product_Tag__c);
        //finally verify the old rules tag assignments have been removed
        List<ADM_Tag_Assignment__c> oldTagAssignments = [select id, record_type__c, Assignment_Rule__c, product_tag__c from ADM_Tag_Assignment__c where Assignment_Rule__c =:rule.id];
        System.assert(oldTagAssignments == null || oldTagAssignments.size() == 0, 'Did not expect to find any tag assignments related to rule.id:' + rule.id + ' but found these:' +oldTagAssignments);
    }

}