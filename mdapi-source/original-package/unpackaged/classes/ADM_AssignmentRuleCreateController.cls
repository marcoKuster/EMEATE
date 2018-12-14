public with sharing class ADM_AssignmentRuleCreateController {
    
    @AuraEnabled
    public static ADM_Assignment_Rule__c saveRule(Id productTagId, String recordType, ADM_Assignment_Rule__c rule) {
        System.debug('inside saveRule()');
        System.debug('inside saveRule() productTagId:' + productTagId + ' recordType:' + recordType + ' rule:' + rule);
        //in LEX insted of showing the matrix view we give a simpler form layout.  therefore we need
        //to disable old rule and insert new ones 
        
        //remove existing tag assignments for this tag, rule and record type
        List<ADM_Tag_Assignment__c> tagAssignments = [select id from ADM_Tag_Assignment__c where Record_Type__c = :recordType and Product_Tag__c = :productTagId];       
        if(tagAssignments != null && tagAssignments.size() > 0) {
            delete tagAssignments;
        }
        
        //insert new assignment rule
        ADM_Assignment_Rule__c newRule = new ADM_Assignment_Rule__c();
        newRule.Assignee_Assignment__c = rule.Assignee_Assignment__c;
        newRule.QA_Assignment__c = rule.QA_Assignment__c;
        newRule.Product_Owner__c = rule.Product_Owner__c;
        newRule.Tech_Writer_Assignment__c = rule.Tech_Writer_Assignment__c;
        newRule.UE_Engineer__c = rule.UE_Engineer__c;
        newRule.Systest_Assignment__c = rule.Systest_Assignment__c;
        newRule.Scrum_Team_Assignment__c = rule.Scrum_Team_Assignment__c;
        newRule.Sev_1_Assignee__c = rule.Sev_1_Assignee__c;
        newRule.Sev_2_Assignee__c = rule.Sev_2_Assignee__c;
        newRule.Sev_3_Assignee__c = rule.Sev_3_Assignee__c;
        newRule.Sev_4_Assignee__c = rule.Sev_4_Assignee__c;
        newRule.Senior_Management_POC_Assignment__c = rule.Senior_Management_POC_Assignment__c;
        
        insert newRule;
        
        //relate new rule to product tag with new tag assignments
        ADM_Tag_Assignment__c newTagAssignment = new ADM_Tag_Assignment__c();
        newTagAssignment.Assignment_Rule__c = newRule.id;
        newTagAssignment.Product_Tag__c = productTagId;
        newTagAssignment.Record_Type__c = recordType;
        insert newTagAssignment;
        
        
        //return new rule
        return newRule;
        
    }

}