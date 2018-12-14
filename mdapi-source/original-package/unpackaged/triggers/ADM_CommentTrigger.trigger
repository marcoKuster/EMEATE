trigger ADM_CommentTrigger on ADM_Comment__c (before insert) {
	
	//custom created by and create date fields exist on Comment to preserve the original comment data from bugforce (vs the date they were imported)
	
	for(ADM_Comment__c c : Trigger.new) {
		if(c.Comment_Created_By__c == null) {
			c.Comment_Created_By__c = UserInfo.getUserId();
		}
		
		if(c.Comment_Created_Date__c == null) {
			c.Comment_Created_Date__c = System.now();
		}
		
		//Set Posted_to_Chatter only if the Comment field has text
		if(!ADM_TextUtils.isBlank(c.Body__c)){
            c.Posted_to_Chatter__c = true;
        }
    }
	
}