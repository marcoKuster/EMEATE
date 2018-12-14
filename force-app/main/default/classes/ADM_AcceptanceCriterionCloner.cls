public with sharing class ADM_AcceptanceCriterionCloner implements ADM_DeepCloneInterface {

	 public static void clone(Id originalWorkID, Id clonedWorkID) { 
	 	
	 	try {
		 	List<ADM_Acceptance_Criterion__c> clonedList = new List<ADM_Acceptance_Criterion__c>();
	    
	    	for(ADM_Acceptance_Criterion__c original : [select id, Name, Description__c, Status__c from ADM_Acceptance_Criterion__c where Work__c = :originalWorkID]) {
	    		ADM_Acceptance_Criterion__c clone = original.clone(false, true);
	    		clone.Status__c = 'New';
	    		clone.Work__c = clonedWorkID;
	    		clonedList.add(clone);
	    	}
	    	
	    	insert clonedList;
	    } catch (Exception e) {
	        	System.debug('Unexpected exception cloning ac:' + e);
	    }
	    	
	 }
	 public static void cloneAccordingToType(Id originalID, Id cloneID, String whatToClone){}

}