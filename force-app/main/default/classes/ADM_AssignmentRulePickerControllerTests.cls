@IsTest
private class ADM_AssignmentRulePickerControllerTests {
    
    /* Test to make sure the correct assignment rule is returned when the 
     * product tag has previously been related to an assignment rule */
    
    static testmethod void testGetRuleByRecordTypeWhenAssignmentRuleExists() {
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
        System.assert(bugRule.id != null, 'Error setting up test data.  Tag Assignment was not inserted');
        //call the controller and verify we get the expected results back
        List<ADM_AssignmentRulePickerController.TagAssignmentWrapper> wrappers = ADM_AssignmentRulePickerController.getRuleByRecordType(tag.id, 'Bug'); 
        System.assert(wrappers != null && wrappers.size() == 1, 'Unexpected number of tag assignments found for Product Tag:' + tag);
        //verify the product tag is connected to the expected assignment rule
        ADM_AssignmentRulePickerController.TagAssignmentWrapper wrapper = wrappers.get(0);
        System.assertEquals('Bug',wrapper.recordType);
        System.assertEquals(rule.id, wrapper.rule.id);
    }
    
    /*Test to make sure a default assignment rule is initialized for new Product Tags */
    
    static testmethod void testGetRuleByRecordTypeWhenAssignmentRuleDoesNotExist() {
       //setup test team and product tag but deliberately don't relate it to an assignment rule to re-create the conditions
       //of a brand new product tag
        ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTag();
        System.assert(tag.id != null, 'Error setting up test data.  Product Tag was not inserted');
        ADM_Scrum_Team__c team = [select id, Name from ADM_Scrum_Team__c where id =:tag.Team__c];
        System.assert(team.id != null, 'Error setting up test data.  Scrum Team was not inserted');
        //add myself as product owner on new team
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Scrum_Team__c = team.id;
        member.Member_Name__c = UserInfo.getUserId();
        member.Role__c = 'Product Owner';
        insert member;
        
        //call the controller and verify we get a new assignment rule back even though we didn't create one
        List<ADM_AssignmentRulePickerController.TagAssignmentWrapper> wrappers = ADM_AssignmentRulePickerController.getRuleByRecordType(tag.id, 'Bug'); 
        System.assert(wrappers != null && wrappers.size() == 1, 'Unexpected number of tag assignments found for Product Tag:' + tag);
        
        //verify the product tag is connected to an assignment rule and the product owner has been populated
        ADM_AssignmentRulePickerController.TagAssignmentWrapper wrapper = wrappers.get(0);
        System.assertEquals('Bug',wrapper.recordType);
        System.assert(wrapper.rule.id != null);
        System.assert(wrapper.rule.Product_Owner__c != null);
        System.assertEquals(UserInfo.getUserId(), wrapper.rule.Product_Owner__c);
        
        
    }

}