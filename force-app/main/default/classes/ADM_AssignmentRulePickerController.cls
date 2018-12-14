public with sharing class ADM_AssignmentRulePickerController {


    @AuraEnabled
    public static List<TagAssignmentWrapper> getRuleByRecordType(String productTagId, String recordType) {
    	List<TagAssignmentWrapper> results = new List<TagAssignmentWrapper>();

        System.debug('inside getRuleByRecordType() productTagId:' + productTagId + ' recordType:' + recordType);
        List<ADM_Tag_Assignment__c> tagAssignments = [select id, Assignment_Rule__c from ADM_Tag_Assignment__c where Product_Tag__c =:productTagId and Record_Type__c =:recordType limit 1];
        if(tagAssignments != null && tagAssignments.size() == 1) {
            ADM_Assignment_Rule__c rule = [select Name, Scrum_Team_Assignment__c, Product_Owner__c, Product_Owner__r.Name, Assignee_Assignment__c, Assignee_Assignment__r.Name, Tech_Writer_Assignment__c, Tech_Writer_Assignment__r.Name, QA_Assignment__c, QA_Assignment__r.Name, Systest_Assignment__c, Systest_Assignment__r.Name, UE_Engineer__c, UE_Engineer__r.Name, Sev_1_Assignee__c, Sev_2_Assignee__c, Sev_3_Assignee__c, Sev_4_Assignee__c, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c where id =:tagAssignments.get(0).Assignment_Rule__c];
            if(rule != null) {
            	TagAssignmentWrapper wrapper = new TagAssignmentWrapper();
            	wrapper.rule = rule;
                wrapper.recordType = recordType;

                results.add(wrapper);
            }
        } else {
            //create an empty object to init the form
            ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id =:productTagId];
            if(tag != null && tag.Team__c != null) {
                ADM_Assignment_Rule__c newRule = new ADM_Assignment_Rule__c();
                newRule.Scrum_Team_Assignment__c = tag.Team__c;
                insert newRule;
                //init fields with default blank values
                newRule = [select Name, Scrum_Team_Assignment__c, Product_Owner__c, Product_Owner__r.Name, Assignee_Assignment__c, Assignee_Assignment__r.Name, Tech_Writer_Assignment__c, Tech_Writer_Assignment__r.Name, QA_Assignment__c, QA_Assignment__r.Name, Systest_Assignment__c, Systest_Assignment__r.Name, UE_Engineer__c, UE_Engineer__r.Name, Sev_1_Assignee__c, Sev_2_Assignee__c, Sev_3_Assignee__c, Sev_4_Assignee__c, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c where id =:newRule.id];
                //create a tag assignment for the default rule
                ADM_Tag_Assignment__c newTA = new ADM_Tag_Assignment__c();
                newTA.Assignment_Rule__c = newRule.id;
                newTA.Product_Tag__c = productTagId;
                newTA.Record_Type__c = recordType;
                insert newTA;
                TagAssignmentWrapper wrapper = new TagAssignmentWrapper();
                wrapper.recordType = recordType;
                wrapper.rule = newRule;
                results.add(wrapper);
            }

        }
        System.debug('inside getRuleByRecordType() returning results:' + results);
        return results;
    }


    public class TagAssignmentWrapper {
          @AuraEnabled
          public ADM_Assignment_Rule__c rule;
          @AuraEnabled
          public String recordType;
      }   

}