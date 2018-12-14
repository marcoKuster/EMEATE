trigger ADM_AssignmentRuleDeleteTrigger on ADM_Assignment_Rule__c (before delete) {

    //count the number of product tags that are associated to the assignment rules
    Map<Id, Integer> numberOfProductTags = new Map<Id, Integer>();
    Set<Id> oldMapKeySet = Trigger.oldMap.keySet();
    String assignmentRuleOnTagAssignment = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Assignment_Rule__c';
    
    String sobjectTypeName = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'ADM_Tag_Assignment__c';
    String soql = 'select ' + assignmentRuleOnTagAssignment + ', count(Id) from  ' + sobjectTypeName + ' where ' + assignmentRuleOnTagAssignment + ' in :oldMapKeySet group by ' + assignmentRuleOnTagAssignment;
    //List<AggregateResult> countResults = [select Assignment_Rule__c, count(Id) from ADM_Tag_Assignment__c where Assignment_Rule__c in :Trigger.oldMap.keySet() group by Assignment_Rule__c];
    for(AggregateResult result : Database.query(soql)) {
        Id assignmentRuleId = (Id)result.get(assignmentRuleOnTagAssignment);
        Integer count = (Integer)result.get('expr0');
        
        numberOfProductTags.put(assignmentRuleId, count);
    }

    for(ADM_Assignment_Rule__c assignmentRule : Trigger.old) {
        
        //ensure that the product tag does not have any assignment rules associated
        Integer productTagCount = numberOfProductTags.get(assignmentRule.Id);
        if(productTagCount > 0) {
           assignmentRule.addError('Assignment Rule cannot be deleted because it is used by ' + (productTagCount == 1 ? 'a ' : '') + 'Product Tag' + (productTagCount > 1 ? 's' : '') + '. Make sure the Assignment Rule is not assigned to any Product Tags before deleting.');
        }
    }
}