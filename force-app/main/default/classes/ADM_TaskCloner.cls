public with sharing class ADM_TaskCloner implements ADM_DeepCloneInterface {
	
	public static void clone(Id originalWorkID, Id clonedWorkID) {
	 	
	 	try {
		 	List<ADM_Task__c> clonedList = new List<ADM_Task__c>();
	    
	    	for(ADM_Task__c original : [select Assigned_To__c, Subject__c, Comments__c, Starting_Hours__c from ADM_Task__c where Work__c = :originalWorkID]) {
	    		ADM_Task__c clone = original.clone(false, true);
	    		clone.Hours_Remaining__c = original.Starting_Hours__c;
	    		clone.Actual_Hours__c = null;
	    		clone.Status__c = 'Not Started';
	    		clone.Work__c = clonedWorkID;
	    		clonedList.add(clone);
	    	}
	    	
	    	insert clonedList;
	    } catch (Exception e) {
	        	System.debug('Unexpected exception cloning tasks:' + e);
	   }	
	 }
	 public static void cloneAccordingToType(Id originalID, Id cloneID, String whatToClone){}

}