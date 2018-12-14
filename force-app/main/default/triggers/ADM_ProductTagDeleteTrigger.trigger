trigger ADM_ProductTagDeleteTrigger on ADM_Product_Tag__c (before delete, after delete) {

    //count the number of assignment rules that are associated to the product tags
    Map<Id, Integer> numberOfAssignmentRules = new Map<Id, Integer>();
    String pTagOnTagAssignment = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Product_Tag__c';
    List<AggregateResult> countResults = [select Product_Tag__c, count(Id) from ADM_Tag_Assignment__c where Product_Tag__c in :Trigger.oldMap.keySet() group by Product_Tag__c];
    private String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
    for(AggregateResult result : countResults) {
        Id productTag = (Id)result.get(pTagOnTagAssignment);
        Integer count = (Integer)result.get('expr0');
        
        numberOfAssignmentRules.put(productTag, count);
    }
    
    //count the number of work
    Map<Id, Integer> numberOfWorkRecords = new Map<Id, Integer>();
    List<AggregateResult> workCountResults = [select Product_Tag__c, count(Id) from ADM_Work__c where Product_Tag__c in :Trigger.oldMap.keySet() group by Product_Tag__c limit 1000];
    for(AggregateResult workCountResult : workCountResults) {
        String productTagString = nameSpacePrefix + 'Product_Tag__c';
        Id productTag = (Id)workCountResult.get(productTagString);
        Integer count = (Integer)workCountResult.get('expr0');
        
        numberOfWorkRecords.put(productTag, count);
    }

    for(ADM_Product_Tag__c productTag : Trigger.old) {
        
        //ensure that the product tag does not have any assignment rules associated
        Integer assignmentRuleCount = numberOfAssignmentRules.get(productTag.Id);
        if(assignmentRuleCount > 0) {
           productTag.addError('Product Tag cannot be deleted because it is used by ' + (assignmentRuleCount == 1 ? 'an ' : '') + 'Assignment Rule' + (assignmentRuleCount > 1 ? 's' : '') + '. Make sure the product tag is not assigned to any Assignment Rules before deleting.');
        }
        
        //ensure that the product tag does not have any work associated
        Integer workRecordCount = numberOfWorkRecords.get(productTag.Id);
        if(workRecordCount > 0) {
            productTag.addError('Spare a thought for the orphans! This Product Tag can\'t be deleted because it is associated to ' + ((workRecordCount >= 1000) ? 'over ' : '') + ((workRecordCount == 1) ? 'a Work record': workRecordCount + ' Work records') + '. The work records, including closed records, will need to be associated to a different Product Tag in order for this to be deleted. This is best accomplished by creating an enhanced list view from the Work tab.');
        }
    }

    try{
        Set<Id> tagIdSet = Trigger.oldMap.keySet();
        List<ADM_Additional_Field__c> additionalFieldsToBeDeleted = new List<ADM_Additional_Field__c>();
        additionalFieldsToBeDeleted = [select id from ADM_Additional_Field__c where Product_Tag__c in : tagIdSet];
        System.debug(additionalFieldsToBeDeleted);
        delete additionalFieldsToBeDeleted;
    }
    catch(Exception e){
        System.debug('Exception while deleting Additional Fields : '+e);
    }        
}