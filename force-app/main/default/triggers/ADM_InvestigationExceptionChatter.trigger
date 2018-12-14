trigger ADM_InvestigationExceptionChatter on ADM_Investigation_Exception__c (after insert) {
    List<Map<String,String>> subs2create = new List<Map<String,String>>();
    for(ADM_Investigation_Exception__c ie : trigger.new) {
        if(ie.Assigned_To__c != null) {
            Map<String,String> assignee = new Map<String,String>();
            assignee.put(ie.Id,ie.Assigned_To__c);
            subs2create.add(assignee);
        }
        if(ie.Requestor__c != null && ie.Requestor__c != ie.Assigned_To__c) {
        	Map<String,String> requestor = new Map<String,String>();
        	requestor.put(ie.Id, ie.Requestor__c);
        	subs2create.add(requestor);
        }
    }

    if(subs2create.size() > 0) {
        ADM_Chatter.massCreate(subs2create);
    }
}