trigger ADM_ProductTagTrigger on ADM_Product_Tag__c (before insert, before update, after delete) {
	boolean orgCacheFlushed = false;
	final String PTAG_CACHE_KEY = 'CachedPTagList';
	final String PTAG_CACHE_KEY_COUNT = 'CachedPTagKeyCount';

	/*
			Check org Cache has been flushed once in this Trigger context, if yes no need to repeat.
	*/
	if(!orgCacheFlushed){
			orgCacheFlushed = flushPTagCache();
	}
  //Adding the below check as we are adding Delete also to trigger
	if(Trigger.isUpdate || Trigger.isInsert){
	//create unique key based on team name and tag name to enforce uniqueness per team
	for(ADM_Product_Tag__c tag : Trigger.new) {
		tag.team_tag_key__c = tag.team__c + '@' + tag.name;
	}
	
	/* Enforce only one tag has automated tools box checked per team.  1st
	   check if any records in this batch have Use For Automated Tools box 
	   checked and if so store Team ID
	*/
	List<Id> teamIDs = new List<Id>();
	for(ADM_Product_Tag__c tag: Trigger.New) {
        if(tag.Use_for_Automated_Tools__c) {
        	teamIDs.add(tag.Team__c);
        }
	}    
	
	//Since teams in this list have specified a new tag to use with automated tools we need to uncheck their prior selection
	List<ADM_Product_Tag__c> priorSelections = [select id from ADM_Product_Tag__c where Team__c in:teamIDs 
												and Use_for_Automated_Tools__c = true and id not in:Trigger.New];
	
	for(ADM_Product_Tag__c tag2 : priorSelections) {
		tag2.Use_for_Automated_Tools__c = false;
	}
	
	update priorSelections;
	}
	
	//if tag.team has changed we need to remove the tag assignments for the former team.  The user will then be prompted to create new tag assignments based on the new team's rules 
	if(Trigger.isUpdate) {
		List<Id> tagsWhoNeedAssignmentsRemoving = new List<Id>();
		Integer i = 0;
		for(ADM_Product_Tag__c tag: Trigger.New) {
	        if(Trigger.old.get(i).Team__c != Trigger.new.get(i).Team__c) {
	        	tagsWhoNeedAssignmentsRemoving.add(tag.id);
	        }
	        i++;
		}
		
		/*
		Call removeTagAssignments() which is async and check that we are not already in the future context to prevent a recursive loop since ADM_Tag_Assignment has a 
		delete trigger which can cause Product Tag Edit trigger to fire again. 
		*/
		if(!System.isFuture()) {
			//remove tag assignments for this tag as it is being assigned to a new team 
			ADM_ProductTagUtils.removeTagAssignments(tagsWhoNeedAssignmentsRemoving);
		}	  
	}
	
	private boolean flushPTagCache(){
			try{
					 Integer cacheKeyCounter =(Integer) ADM_OrgCacheManager.get(PTAG_CACHE_KEY_COUNT);
					 List<String> pTagCacheKeysList = new List<String>();
					 System.debug('ptag cacheKeyCounter '+ cacheKeyCounter);
					 if(cacheKeyCounter != null){
						 for(Integer keyCount = 0; keyCount < cacheKeyCounter; keyCount++){
								 pTagCacheKeysList.add(PTAG_CACHE_KEY + keyCount);
								 ADM_OrgCacheManager.put(PTAG_CACHE_KEY + keyCount, new List<ADM_Product_Tag__c>());
						}

						pTagCacheKeysList.add(PTAG_CACHE_KEY_COUNT);
						System.debug(' removing ' + pTagCacheKeysList);
						ADM_OrgCacheManager.remove(pTagCacheKeysList);
					}
					orgCacheFlushed = true;

			}
			catch(Exception exp){
				  //If exception happened don't want the flushing activity to repeat...so setting the flag to true.
				  orgCacheFlushed = true;
					ADM_ExceptionHandler.saveException(exp, 'CacheException happened while flushOrgCache method in ADM_Product Tag trigger' + exp + ' Line:' + exp.getLineNumber());
			}
			return orgCacheFlushed;

	}

	
}