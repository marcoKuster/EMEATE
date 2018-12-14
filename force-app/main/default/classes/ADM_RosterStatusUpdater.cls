public class ADM_RosterStatusUpdater implements Database.Batchable<sObject>, Schedulable {
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new ADM_RosterStatusUpdater(), 200);
	}


	//Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
         String [] offerStrings = new String []{'Offer In Progress', 'Offer Accepted'};
         string query = 'Select Id, Status__c, Target_Start_Date__c, Candidate_Name__c, Recruiter__c from HeadCount__c where status__c in :offerStrings and target_Start_Date__c <= today';
         //execute the Query
         return Database.getQueryLocator(query);
     }

     public void execute(Database.BatchableContext BC, List<HeadCount__c> rosters){ 
        
        processRosters(rosters);
        
     }

     public void processRosters(List<HeadCount__c> rosters){ 
     	Set<String> candidatesMissingUserRecords = new Set<String>();
        Map<String,List<User>> nameToUserRecordMap = new Map<String,List<User>>();
        Map<String, List<HeadCount__c>> candidateNameToRoster = new Map<String, List<HeadCount__c>>();

        /*
			Iterate over roster records in this batch and create a map with Candidate name as key and Roster record as value.
			If Candidate name is repeated for for eg: Joe Tom [ 2 different candidates] has two roster records, then this
			automated process will ignore both the rosters as it will not be able to correctly judge which record belongs to which
			candidate.

        */
        if(rosters.size() > 0) {
        	System.debug(' inside if rosters.size()'+ rosters.size());
            for(HeadCount__c roster: rosters){
            	List<Headcount__c> headcountList = new List<Headcount__c>();
                if(roster.Candidate_Name__c != null){
                    headcountList = candidateNameToRoster.get(roster.Candidate_Name__c.toLowerCase());
                    if(headcountList == null ){
            		headcountList = new List<Headcount__c> ();
            	}
            	headcountList.add(roster);
            	candidateNameToRoster.put(roster.Candidate_Name__c.toLowerCase(), headcountList);
            }

            }
        }

        /*
			Creating a map of candidate name with user record as value.

			candidatesMissingUserRecords is initialized to all candidate names before we get into the loop.

			Once we iterate over the list we remove name from candidatesMissingUserRecords set which as a user record.
        */

        List<User> usersFromCandidateNames = new List<User>();
        if(candidateNameToRoster != null && candidateNameToRoster.size() >0){
        	candidatesMissingUserRecords.addAll(candidateNameToRoster.keySet()); //Adding all names initially
        	usersFromCandidateNames = [Select id, Name, EmployeeNumber from User where Name in :candidateNameToRoster.keySet() and isActive = true and EmployeeNumber not in (null , 'TBD')  ];
        	for(User user: usersFromCandidateNames){
        		if(nameToUserRecordMap.containsKey(user.Name.toLowerCase())){
        			List<User> userListFromMap = nameToUserRecordMap.get(user.Name.toLowerCase());
        			userListFromMap.add(user);
        		}
        		else{
        			nameToUserRecordMap.put(user.Name.toLowerCase(), new List<User>{user});
        		}
                candidatesMissingUserRecords.remove(user.Name.toLowerCase());//Removing name from the missing set if we were able to find user record.
        	}
        }

        System.debug(' candidatesMissingUserRecords'+ candidatesMissingUserRecords);
        /*
		   Finding roster records from the user records returned by querying user object with Candidate names

        */
        HeadCount__c[] existingRosters = [Select id, Headcount_Name__c, Candidate_Name__c, Recruiter__c from HeadCount__c where Headcount_Name__c in :usersFromCandidateNames];
        Set<String> usersWithRosterRecord = new Set<String>();
        for(HeadCount__c headCount: existingRosters){
        	usersWithRosterRecord.add(headCount.Headcount_Name__c); //Headcount_Name__c is Id of user 
        }

        for(String name: nameToUserRecordMap.keySet()){
        	List<User> userListFromMap = nameToUserRecordMap.get(name);
			System.debug(' userListFromMap '+ userListFromMap);
        	if(userListFromMap.size() > 1 ){
        		List<User> parallelListToIterate = new List<User>();//Cannot dynamically remove value from a list over iteration
        		parallelListToIterate.addAll(userListFromMap);
        		Integer index = 0;
        		for(User user: parallelListToIterate){
        			if(usersWithRosterRecord.contains(user.Id)){
        				userListFromMap.remove(index);// This should eventually get down to one user record in the list - As rest of all other user records will have a Roster assigned to it.
        			}
        			index++;
        		}
        	}
        	else if(userListFromMap.size() == 1 ){
        		if(usersWithRosterRecord.contains(userListFromMap[0].Id)){//Found only one user record and that user already has a roster account
        			candidatesMissingUserRecords.add(name.toLowerCase());
        				
        		}

        	}
        }

        /******

        Issue findings ......

        ***/
        Set<String> nameVerifiedSet = new Set<String>();
        List<Headcount__c> nameWithMultipleRosters = new List<HeadCount__c>();
        List<Headcount__c> namesWithNoUserRecords = new List<HeadCount__c>();
        List<Headcount__c> namesWithMultipleUserRecords = new List<Headcount__c>();
        List<Headcount__c> headcountsToUpdate = new List<Headcount__c>();
        for(String name : candidateNameToRoster.keySet()){
        	List<Headcount__c> headCountsWithThisName = candidateNameToRoster.get(name);
        	if(!nameVerifiedSet.contains(name.toLowerCase())){
        		nameVerifiedSet.add(name.toLowerCase());
	        	System.debug(' headCountsWithThisName '+ headCountsWithThisName);
	        	if(headCountsWithThisName.size() > 1){
	        		System.debug(' more than one roster with this name');
	        		for(Headcount__c headcount : headCountsWithThisName){
	        			nameWithMultipleRosters.add(headcount);
	        			continue;
	        		}
	        		
	        	}
        	}
        	System.debug(' candidatesMissingUserRecords going inside candidatesMissingUserRecords');
			if(candidatesMissingUserRecords.contains(name.toLowerCase())){
				namesWithNoUserRecords.add(headCountsWithThisName[0]);
        		continue;
        	}
        	if(nameToUserRecordMap.size() >0){

        		List<User> userListFromMap = nameToUserRecordMap.get(name.toLowerCase());
        		System.debug(' userListFromMap '+ userListFromMap);
        		if(userListFromMap.size() > 1){
        			namesWithMultipleUserRecords.add(headCountsWithThisName[0]);
        		}
        		else if(userListFromMap.size() == 1){
				headCountsWithThisName[0].Headcount_Name__c = userListFromMap[0].Id;
        			headcountsToUpdate.add(headCountsWithThisName[0]);
        		}
        	}

        	
        }

        if(headcountsToUpdate.size() >0){

            Set<String> fields = new Set<String>();
            fields.add('Status__c');
            fields.add('Headcount_Name__c');
            if(!ADM_SchemaManager.areFieldsUpdateable('Headcount__c',fields)){
		throw new DMLException('The Headcount__c.Headcount_Name__c field is not updateable');                
            }

            Database.update(headcountsToUpdate, false);
    	}

    	System.debug(' nameWithMultipleRosters '+ nameWithMultipleRosters);
    	System.debug(' namesWithNoUserRecords '+ namesWithNoUserRecords);
    	System.debug(' namesWithMultipleUserRecords '+ namesWithMultipleUserRecords);
    	if(nameWithMultipleRosters.size() >0){
    		postIssuesToChatterOnMultipleRosters(nameWithMultipleRosters);
    	}

    	if(namesWithNoUserRecords.size() >0){
    		postIssuesToChatterOnNoUserRecordsFound(namesWithNoUserRecords);
    	}

    	if(namesWithMultipleUserRecords.size() >0){
    		postIssuesToChatterOnMultipleUserRecords(namesWithMultipleUserRecords);
    	}
     }

     private void postIssuesToChatterOnMultipleRosters(List<Headcount__c> nameWithMultipleRosters){
     	postIssuesToChatter(nameWithMultipleRosters, 
     		                   ' This is posted by an automated job in GUS. If you have questions please contact GUS Team. The job was trying to change status of this Roster to Filled, but it failed as there are more than one Roster record in the list with the same candidate name');
             	 
             

     }

     private void postIssuesToChatterOnNoUserRecordsFound(List<Headcount__c> namesWithNoUserRecords){
     	postIssuesToChatter(namesWithNoUserRecords, 
     		                   ' This is posted by an automated job in GUS. If you have questions please contact GUS Team. The job was trying to change status of this Roster to Filled, but it failed as it couldnot find one user record with below criterias\n'+
                                   'a) Candidate Name matches exactly one Active user in GUS \n b) EmployeeNumber not null or "TBD" \n c) Not assigned to any other Roster record ');
             	 
             

     }

     private void postIssuesToChatterOnMultipleUserRecords(List<Headcount__c> namesWithMultipleUserRecords){
     	postIssuesToChatter(namesWithMultipleUserRecords, 
     		                   ' This is posted by an automated job in GUS. If you have questions please contact GUS Team. The job was trying to change status of this Roster to Filled, but it failed as there are more than one user records associated to this Candidate Name');
             	 
             

     }

     private void postIssuesToChatter(List<Headcount__c> rosters, String textToChatter){
     	try {
     		  
 		  	List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
 		  	for(Headcount__c roster: rosters){
 		  		System.debug(' inside rosters'+ rosters);
 		  		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
	          	ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
	          	ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
	          	ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

	         	messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
	         	System.debug(' inside roster '+ roster);
	         	mentionSegmentInput.id = roster.Recruiter__c;
	         	System.debug(' inside mentionSegmentInput'+ mentionSegmentInput);
	            messageBodyInput.messageSegments.add(mentionSegmentInput);
	            
                textSegmentInput.text = textToChatter;
             	 
             	messageBodyInput.messageSegments.add(textSegmentInput);

	          	feedItemInput.body = messageBodyInput;
	          	feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
	        	feedItemInput.subjectId = roster.Id;
	        	System.debug('  feedItemInput '+ feedItemInput);
	        	ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

	        	batchInputs.add(batchInput);

 		  	}
 		  	ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
     
	     } catch (Exception e) {
          System.debug('Error while posting about multiple roster records');
      	}

     }

     //Finish Method
     public void finish(Database.BatchableContext BC){
         
         
     }


}