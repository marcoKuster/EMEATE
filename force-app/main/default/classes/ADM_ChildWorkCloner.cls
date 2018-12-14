public with sharing class ADM_ChildWorkCloner implements ADM_DeepCloneInterface {

	 public static void cloneAccordingToType(Id originalWorkID, Id clonedWorkID, String whatToClone) { 
	 	
	 	try {
		 	List<ADM_Parent_Work__c> clonedList = new List<ADM_Parent_Work__c>();
			List<Id> childRecordsToBeCloned = new List<Id>();   
	    	for(ADM_Parent_Work__c originalRelationShip : [select id, Child_Work__c from ADM_Parent_Work__c where Parent_Work__c = :originalWorkID]) {
	    		if(whatToClone == 'Relationships'){
		    		ADM_Parent_Work__c clone = originalRelationShip.clone(false, true);
		    		clone.Parent_Work__c = clonedWorkID;
		    		clonedList.add(clone);
	    		}
	    		else{
	    			childRecordsToBeCloned.add(originalRelationShip.Child_Work__c);
	    		}
	    	}
	    	
	    	if(whatToClone == 'Records and Relationships'){
		    	List<ADM_Work__c> childWorkRecords = [Select Name, Details__c, Test_Plan__c, Scrum_Team_Name__c, Sprint_Name__c, Attributes__c, Executive_Involved__c,Severity_Level__c,Request_RD_Mgr_Review__c,Critical_CRM_Feature__c,Red_Account__c,Deal_at_Risk__c,Estimated_Financial_Impact__c,Details_and_Steps_to_Reproduce__c, Senior_Management_POC__c, CS_Contact__c, Num_Of_Prod_Occ__c, Scrumforce_ID__c, Budget_ID__c, Additional_Details__c,Use_Prioritizer__c,User_Type__c,Story_Points__c,Priority_Rank__c,Theme__c, Sprint__c, Last_Modified_By_Copy__c,Last_Modified_By__c,Priority_Mapping__c,Priority_Mapping_Copy__c,Priority_Default__c,Priority_Override_Explanation_Copy__c,Priority_Override_Explanation__c,Frequency__c, Impact__c, Impact__r.Name, Preserve_Formatting__c, Preserve_Formatting_Copy__c, Scheduled_Build_Copy__c, Found_In_Build_Copy__c,Root_Cause_Analysis_2__c, Number_of_Cases__c, ftest__c, Type__c, Template_Name__c, Template_Description__c, Tech_Writer__c, System_Test_Engineer__c, UE_Engineer__c, SystemModstamp, Subscribe_to_Work__c, Subject__c, Status__c, Security__c, Scrum_Team__c, Schema__c, Scheduled_On__c, Scheduled_Build__c, Related_URL__c, Regressed__c, RecordType.Name, RecordType.Id,RecordTypeId, QA_Engineer__c, Product_Owner__c, Product_Child__c, Product_Tag__c, Priority__c, Perforce_Status__c, Minor_Func_Area__c, Help_Status__c, Found_in_Build__c, Description__c, Customer__c, Assignee__c  from ADM_Work__c where id IN:childRecordsToBeCloned];
		    	List<ADM_Work__c> workToBeInserted = new List<ADM_Work__c>();
		    	for(ADM_Work__c work : childWorkRecords){
		    		ADM_Work__c clonedChild = work.clone(false,true);
		    		//remove the fields that shouldnt be cloned
            		clonedChild = ADM_WorkUtils.removeFieldsNotApplicableForClone(clonedChild);              
		            //set the fields of the clone
		            clonedChild = ADM_WorkUtils.initializeFieldsForClone(clonedChild);
		            //Set priority properly to avoid errors
		            clonedChild = ADM_WorkUtils.setImpactFrequencyPriorityForClone(work,clonedChild);
		    		workToBeInserted.add(clonedChild);
		    	}
		    	insert workToBeInserted;

		    	for(ADM_Work__c work : workToBeInserted){
		    		ADM_Parent_Work__c childWorkRelationship = new ADM_Parent_Work__c();
		    		childWorkRelationship.Parent_Work__c = clonedWorkID;
		    		childWorkRelationship.Child_Work__c = work.Id;
		    		clonedList.add(childWorkRelationship);
		    	}
	    	}
	    	insert clonedList;

	    } catch (Exception e) {
	        	System.debug('Unexpected exception cloning child work:' + e);
	    }
	    	
	 }

	 public static void clone(Id originalWorkID, Id clonedWorkID) { }

}