public with sharing class ADM_WorkCommentsController{
	public ADM_Work__c work { get; set; }

    public ADM_Comment__c[] getComments() {
    	try {
    		return ADM_Comment.getAllComments(work.Id);
    	} catch(System.Exception e) {
    		System.debug('Unexpected exception fetching comments:' + e);
    		return new List<ADM_Comment__c>();
    	}	
    }

}