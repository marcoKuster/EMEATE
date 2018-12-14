/* 
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
*
* Validates creation of parent-child relationships
*/

trigger ParentWorkTrigger on ADM_Parent_Work__c (before insert, before update, before delete) {
	ADM_Parent_Work__c[] workRelationships = Trigger.new;
    if( Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ) {
    	 
    	 //for each parent/child link in list validate it is not being added to itself
    	 for(ADM_Parent_Work__c link : workRelationships){
    	 	if(link.Parent_Work__c == link.Child_Work__c) {
    	 		link.addError('A work item cannot be related to itself.');	
    	 	}	
    	 }
    }
    
    if(Trigger.isDelete) {
    	//track how many parents each child has
    	Map<Id, List<ADM_Parent_Work__c>> parentCount = new Map<Id, List<ADM_Parent_Work__c>>();
    	Map<Id, List<ADM_Parent_Work__c>> childCount = new Map<Id, List<ADM_Parent_Work__c>>();
    	
    	List<Id> childIDs = new List<Id>();
    	List<Id> parentIDs = new List<Id>();
    	
    	for(ADM_Parent_Work__c link : Trigger.old){
    		childIDs.add(link.Child_Work__c);
    		parentIDs.add(link.Parent_Work__c);
    	}
    	
    	List<ADM_Parent_Work__c> parents = [select Child_Work__c, Parent_Work__c from ADM_Parent_Work__c where Child_Work__c in :childIDs];
    	List<ADM_Parent_Work__c> children = [select Child_Work__c, Parent_Work__c from ADM_Parent_Work__c where Parent_Work__c in :parentIDs];
    	
    	//count the number of parents each work record has    	
    	for(ADM_Parent_Work__c p : parents) {
    		if(parentCount.containsKey(p.Child_Work__c)) {
    			List<ADM_Parent_Work__c> existingParents =  parentCount.get(p.Child_Work__c);
    			existingParents.add(p);
    			parentCount.put(p.Child_Work__c, existingParents);
    		} else {
    			parentCount.put(p.Child_Work__c, new List<ADM_Parent_Work__c>{p});
    		}
    	}
    	
    	//count the number of children each work record has    	
    	for(ADM_Parent_Work__c p : children) {
    		if(childCount.containsKey(p.Parent_Work__c)) {
    			List<ADM_Parent_Work__c> existingChildren =  childCount.get(p.Parent_Work__c);
    			existingChildren.add(p);
    			childCount.put(p.Parent_Work__c, existingChildren);
    		} else {
    			childCount.put(p.Parent_Work__c, new List<ADM_Parent_Work__c>{p});
    		}
    	}
    	
    	//lookup the status of the work records
    	Map<Id, ADM_Work__c> populatedWork = new Map<Id, ADM_Work__c>([select id, status__c from ADM_Work__c where id in:childIDs or id in:parentIDs ]);
    	
    	for(ADM_Parent_Work__c link : Trigger.old){
    	 	//if the child's status is duplicate prevent the removal of the last parent
    	 	ADM_Work__c child = populatedWork.get(link.Child_Work__c);
    	 	if(ADM_Validate.STATUS_VALUES_WHICH_REQUIRE_PARENT.contains(child.Status__c) && parentCount.containsKey(link.Child_Work__c) && parentCount.get(link.Child_Work__c).size() == 1) {
    	 		link.addError('You cannot remove the only remaining parent of a work record with a status of "Duplicate" or "Closed - Duplicate".');	
    	 	}	
    	 	
    	 	//for Investigation record types if the parents status is Closed - New Bug Logged' or 'Closed - Known Bug Exists' prevent the removal of the last child
    	 	ADM_Work__c parent = populatedWork.get(link.Parent_Work__c);
    	 	if(ADM_Validate.STATUS_VALUES_WHICH_REQUIRE_CHILD.contains(parent.Status__c) && childCount.containsKey(link.Parent_Work__c) && childCount.get(link.Parent_Work__c).size() == 1) {
    	 		link.addError('You cannot remove the only remaining child of a work record with a status of "Closed - New Bug Logged" or "Closed - Known Bug Exists".');	
    	 	}
    	 	
    	 }
    }
    
}