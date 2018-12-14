trigger RetroBeforeDelete on Retrospective__c (before delete) {

    String currentUserId = UserInfo.getUserId();
    for(Retrospective__c retro : Trigger.old) {
        // Retros only with status "new" can be deleted.    
        if(retro.Status__c != RetrospectiveControllerExtension.STATUS_NEW) {
            if (currentUserId == retro.User__c || currentUserId == retro.Manager__c) {
                retro.addError('Your attempt to delete ' + retro.Name + ' could not be completed because its status is ' + retro.Status__c + '.');
            }
        }            
                 
                 
    }
}