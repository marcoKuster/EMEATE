public with sharing class ADM_ProductTagUtils {
	
		
	/*
		@future to prevent recursive loop since ADM_Tag_Assignment has a delete trigger which can cause Product Tag Edit trigger to fire which calls this method.
		Without it and an isFuture context check in the trigger a "SELF_REFERENCE_FROM_TRIGGER, Object is currently in trigger ADM_ProductTagTrigger, therefore 
		it cannot recursively update itself" error will be thrown
	*/
	
	@future
	public static void removeTagAssignments(List<Id> tagAssignmentIDs) {
		List<ADM_Tag_Assignment__c> formerAssignments = [select id from ADM_Tag_Assignment__c where Product_Tag__c in :tagAssignmentIDs];
		delete formerAssignments;  
	}
	

}