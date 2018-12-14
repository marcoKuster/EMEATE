public with sharing class ADM_ParentWorkCloner implements ADM_DeepCloneInterface {

	 public static void cloneAccordingToType(Id originalWorkID, Id clonedWorkID, String whatToClone) { 
	 	
	 	try {
		 	List<ADM_Parent_Work__c> clonedList = new List<ADM_Parent_Work__c>();
		 	List<Id> parentRecordsToBeCloned = new List<Id>();
	    	for(ADM_Parent_Work__c originalRelationShip : [select id, Parent_Work__c from ADM_Parent_Work__c where Child_Work__c = :originalWorkID]) {
	    		if(whatToClone == 'Relationships'){
		    		ADM_Parent_Work__c clonedRelationship = originalRelationShip.clone(false, true);
		    		clonedRelationship.Child_Work__c = clonedWorkID;
		    		clonedList.add(clonedRelationship);
	    		}
	    		else{
	    			parentRecordsToBeCloned.add(originalRelationShip.Parent_Work__c);
	    		}
	    	}
	    	
	    	if(whatToClone == 'Records and Relationships'){
		    	List<ADM_Work__c> parentWorkRecords = [Select Name, Details__c, Test_Plan__c, Scrum_Team_Name__c, Sprint_Name__c, Attributes__c, Executive_Involved__c,Severity_Level__c,Request_RD_Mgr_Review__c,Critical_CRM_Feature__c,Red_Account__c,Deal_at_Risk__c,Estimated_Financial_Impact__c,Details_and_Steps_to_Reproduce__c, Senior_Management_POC__c, CS_Contact__c, Num_Of_Prod_Occ__c, Scrumforce_ID__c, Budget_ID__c, Additional_Details__c,Use_Prioritizer__c,User_Type__c,Story_Points__c,Priority_Rank__c,Theme__c, Sprint__c, Last_Modified_By_Copy__c,Last_Modified_By__c,Priority_Mapping__c,Priority_Mapping_Copy__c,Priority_Default__c,Priority_Override_Explanation_Copy__c,Priority_Override_Explanation__c,Frequency__c, Impact__c, Impact__r.Name, Preserve_Formatting__c, Preserve_Formatting_Copy__c, Scheduled_Build_Copy__c, Found_In_Build_Copy__c,Root_Cause_Analysis_2__c, Number_of_Cases__c, ftest__c, Type__c, Template_Name__c, Template_Description__c, Tech_Writer__c, System_Test_Engineer__c, UE_Engineer__c, SystemModstamp, Subscribe_to_Work__c, Subject__c, Status__c, Security__c, Scrum_Team__c, Schema__c, Scheduled_On__c, Scheduled_Build__c, Related_URL__c, Regressed__c, RecordType.Name, RecordType.Id,RecordTypeId, QA_Engineer__c, Product_Owner__c, Product_Child__c, Product_Tag__c, Priority__c, Perforce_Status__c, Minor_Func_Area__c, Help_Status__c, Found_in_Build__c, Description__c, Customer__c, Assignee__c  from ADM_Work__c where id IN:parentRecordsToBeCloned];
		    	List<ADM_Work__c> workToBeInserted = new List<ADM_Work__c>();
		    	for(ADM_Work__c work : parentWorkRecords){
		    		ADM_Work__c clonedParent = work.clone(false,true);
		    		//remove the fields that shouldnt be cloned
            		clonedParent = ADM_WorkUtils.removeFieldsNotApplicableForClone(clonedParent);              
		            //set the fields of the clone
		            clonedParent = ADM_WorkUtils.initializeFieldsForClone(clonedParent);
				    //set priority properly to avoid errors
				    clonedParent = ADM_WorkUtils.setImpactFrequencyPriorityForClone(work,clonedParent);
		    		workToBeInserted.add(clonedParent);
		    	}
		    	insert workToBeInserted;

		    	for(ADM_Work__c work : workToBeInserted){
		    		ADM_Parent_Work__c parentWorkRelationship = new ADM_Parent_Work__c();
		    		parentWorkRelationship.Child_Work__c = clonedWorkID;
		    		parentWorkRelationship.Parent_Work__c = work.Id;
		    		clonedList.add(parentWorkRelationship);
		    	}
	    	}
	    	insert clonedList;

	    } catch (Exception e) {
	        	System.debug('Unexpected exception cloning parents:' + e);
	    }
	    	
	 }
	 public static void clone(Id originalWorkID, Id clonedWorkID) { }

}