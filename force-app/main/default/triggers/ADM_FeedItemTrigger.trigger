trigger ADM_FeedItemTrigger on FeedItem (after insert) {
    List<Id> workIdsFromPost = new List<Id>();
    List<Id> workIdsForSLAUpdate = new List<Id>();
    FeedItem[] newPosts = Trigger.new;
    try{
        String workKeyPrefix = ADM_Work__c.sObjectType.getDescribe().getKeyPrefix();
        for(FeedItem post: newPosts){
            Id parentId = post.ParentId;
            if(null != parentId && ((String) parentId).startsWith(workKeyPrefix)){
                workIdsFromPost.add(parentId);
                
                // add workId for SLA update check, if body does not contain "#nosla"
                if (post.Body!=null && !post.Body.containsIgnoreCase('#nosla')) {
                    workIdsForSLAUpdate.add(parentId);
                }
            }
        }
        if(workIdsFromPost.size() > 0) {
            try{
                ADM_WorkUtils.sendEmailToAssigneesOnFeedPost(workIdsFromPost);
            }
            catch(System.Exception e ){
                ADM_ExceptionHandler.saveException(e, 'Exception sending email to Assignees on Work Item Chatter post:' + e + ' workIdsFromPost:' + workIdsFromPost);
            }
        }
        if (workIdsForSLAUpdate.size() > 0) {
            try{
                // Adding for Missing SLA Project, update its parentId.
                ADM_WorkSLAMonitoringHelper.resetInvestigationSLAsFromChatter(workIdsForSLAUpdate);
            }
            catch(System.Exception e ){
                ADM_ExceptionHandler.saveException(e, 'SLA Exception resetting Investigation SLA on Work Item Chatter post:' + e + ' workIdsForSLAUpdate:' + workIdsForSLAUpdate);
            }
        }
    }
    catch(System.Exception e ){
        //log the error
        ADM_ExceptionHandler.saveException(e, 'Exception in ADM_FeedItemTrigger:' + e + ' newPosts:' + newPosts);
    }
}