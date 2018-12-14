trigger ADM_Changelist_Update_Work on ADM_Change_List__c (after insert) {
    Set<String> workIds = new Set<String>();
    
    for(ADM_Change_List__c el : Trigger.new) {
        if(el.Work__c != null){
        workIds.add(el.Work__c);
    }
    
    }
    if(workIds != null && workIds.size() > 0){
    Map<Id,ADM_Work__c> works = new Map<Id,ADM_Work__c>([select Id, Number_of_Change_Lists__c from ADM_Work__c where Id in : workIds]);
    String workOnChangeList = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Work__c';
    String soql = 'select '+ workOnChangeList + ', count(Id) from ADM_Change_List__c where '+ COM_SoqlUtils.createInClause(workOnChangeList, workIds) +' group by '+ workOnChangeList;
    List<AggregateResult> results = Database.query(soql);
    
    for(AggregateResult result : results) {
        ADM_Work__c work = works.get(String.valueOf(result.get(workOnChangeList)));
        work.Number_of_Change_Lists__c = Integer.valueOf(result.get('expr0'));
        works.put(work.Id, work);          
    }
    
    try {
        update works.values();
    } catch(System.DmlException e) {
        //log the error
        ADM_ExceptionHandler.saveException(e, 'updating work record from ADM_Changelist_Update_Work.trigger');  
    }
}

}