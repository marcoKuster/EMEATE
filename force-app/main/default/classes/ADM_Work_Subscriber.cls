//This class is witout sharing since the apex here needs to be able to edit entity subscriptions owned by others users.
public without sharing class ADM_Work_Subscriber { 
	
	public static List< ADM_Work_Subscriber__c> get( String Id){
	
		return ADM_Work_Subscriber.getByList(new List<Id>{Id});
	}
	
	public static List< ADM_Work_Subscriber__c> getByList( List<Id> workIDs){
	
		List< ADM_Work_Subscriber__c > ws = new List< ADM_Work_Subscriber__c >();
		
		ws = [ 
			Select 
				Always_Send__c, CreatedById, CreatedDate, Id, Name, 
				UserId__c, UserId__r.Name, UserId__r.Email , 
				WorkId__c, WorkId__r.Id, WorkId__r.Name, Distribution_List__c, Assignment_Type__c 
			from 
				ADM_Work_Subscriber__c
			Where 
				WorkId__c in :workIDs
			Order By 
				CreatedDate 
		];
		
		return ws;	
	}

	/*
			This method is called from ADM_Work_SubscriberTrigger.trigger - every time "AFTER" "INSERT"  happen
		
	*/

	public static void addWorkEntitySubscribers(Set<Id> parentWorkIds, Map<String,Set<String>> separatedIDAndNonIDSubscribersFromWork, Map<String, Set<String>> workId2OtherRecipientIdOrEmail){
	   	Map<Id, User> uMap = new Map<Id, User>(ADM_WorkUser.getUsers(separatedIDAndNonIDSubscribersFromWork)); //ADM_Work_Subscriber will have userid__c and distribution_list__c field depending on how it is filled 
		List<EntitySubscription> existingEntitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(parentWorkIds, new Set<Id>()); //1 SOQL for the entire list of ADM_Work_Subscribers
		
		Map<String,EntitySubscription> parentIdSubscriberIdJoinedKey2EntitySubscription = ADM_EntitySubscriptionUtils.getParentIdSubscriberKeyToESMap(existingEntitySubscribers);
		List<EntitySubscription> followers = new List<EntitySubscription>();
		
		ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        Map<String,List<User>> email2UsersMapAfterFederationIdCheck = null;
        if('true' == globalConstants.getIsFederationFieldAvailable()){ //This will save looping over entire users list if FederationIdentifier is not availbale in the org
         email2UsersMapAfterFederationIdCheck =  ADM_WorkUser.getUsersBasedOnFederationIdCheck(uMap.values());
        } 

        Map<Id, Set<String>> alreadyAddedWorkId2SubscriberIdMap = new Map<Id, Set<String>>();
		for(User workUser: uMap.values()){
            List<User> usersAfterFederationIdCheck;
            if(null != email2UsersMapAfterFederationIdCheck){
                usersAfterFederationIdCheck = email2UsersMapAfterFederationIdCheck.get(workUser.email.toLowerCase());
             }
            if(null != usersAfterFederationIdCheck && usersAfterFederationIdCheck.size() == 1){
                /* This email has a user in the ORG who has FederationIdentifier, check if the user being checked is the one with FederationIdentifier if not ignore this user, because if User with FederationIdentifier is available
                   add that user as Subscriber and rest of the users associated to this email (group user, dummy user, test user etc) should be ignored
                   W-2037988
                   https://gus.my.salesforce.com/a07B0000000cyjtIAA
				   At this point one of the two scenarios exists
                         1) This email address has a user with FederationIdentfier; however this user is not one who have FederationIdentifier, so ignoring user and continuing on to next User.
                         2) This user is the only one user associated with this email and user doesnt have FederationIdentifier
                */
                if(workUser.Id != usersAfterFederationIdCheck.get(0).Id){
                  continue;
                }
           }
           for(Id workId: parentWorkIds){

                Set<String> alreadyAddedSubscriberIds = alreadyAddedWorkId2SubscriberIdMap.get(workId);
           	    /*
					One final check to make sure the workId is associated with the user being checked.
				*/
				Set<String> subscriberIdOrEmailSet = workId2OtherRecipientIdOrEmail.get(workId);

				if(null != subscriberIdOrEmailSet && (subscriberIdOrEmailSet.contains(workUser.Id) || subscriberIdOrEmailSet.contains(workUser.Email)
				                            || subscriberIdOrEmailSet.contains(workUser.Alias) || subscriberIdOrEmailSet.contains(workUser.UserName)) ){
					EntitySubscription es = parentIdSubscriberIdJoinedKey2EntitySubscription.get(workId+''+workUser.Id);// needs '' in between to avoid the compilation error Arithmetic expressions must use numeric arguments
	                if(null == es){
                           if(null == alreadyAddedSubscriberIds){
                              alreadyAddedSubscriberIds = new Set<String>();
                           }

                           if(!alreadyAddedSubscriberIds.contains(workUser.id)){//This will avoid duplicate id in the same list issue
	                	   EntitySubscription workFolllower  = new EntitySubscription(parentId=workId, subscriberId=workUser.Id);
		                   followers.add(workFolllower);
                            }
                           
                           alreadyAddedSubscriberIds.add(workUser.Id);//Doesn't matter if workUser.Id already existed Set will ignore duplicate.
	                 	
                           alreadyAddedWorkId2SubscriberIdMap.put(workId, alreadyAddedSubscriberIds);
	                }
            	}
            }
        }

     
        //Adding Entity Subsription for those users who are added to ADM_Work_Subscriber__c  
        ADM_EntitySubscriptionUtils.insertEntitySubscriptions(followers);
	}


	/*
			This method is called from ADM_Work_SubscriberTrigger.trigger - every time "AFTER" "DELETE" happen
		
	*/

	public static void removeWorkEntitySubscribers(Set<Id> parentWorkIds, Map<String,Set<String>> separatedIDAndNonIDSubscribersFromWork, Map<String, Set<String>> workId2OtherRecipientIdOrEmail){
		
       	Map<Id, User> uMap = new Map<Id, User>(ADM_WorkUser.getUsers(separatedIDAndNonIDSubscribersFromWork)); //ADM_Work_Subscriber will have userid__c and distribution_list__c field depending on how it is filled 
		List<EntitySubscription> existingEntitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(parentWorkIds, new Set<Id>()); //1 SOQL for the entire list of ADM_Work_Subscribers
		
		Map<String,EntitySubscription> parentIdSubscriberIdJoinedKey2EntitySubscription = ADM_EntitySubscriptionUtils.getParentIdSubscriberKeyToESMap(existingEntitySubscribers);
		
		List<EntitySubscription> toBeRemovedfollowers = new List<EntitySubscription>();
		Map<Id, Set<String>> alreadyAddedWorkId2SubscriberIdMap = new Map<Id, Set<String>>();
		for(User workUser: uMap.values()){
           for(Id workId: parentWorkIds){
           		Set<String> alreadyAddedSubscriberIds = alreadyAddedWorkId2SubscriberIdMap.get(workId);	
           			if(null == alreadyAddedSubscriberIds){
                              alreadyAddedSubscriberIds = new Set<String>();
                    }
                    if(!alreadyAddedSubscriberIds.contains(workUser.id)){//This will avoid duplicate id in the same list issue
	                	Set<String> subscriberIdOrEmailSet = workId2OtherRecipientIdOrEmail.get(workId);

						if(null != subscriberIdOrEmailSet && (subscriberIdOrEmailSet.contains(workUser.Id) || subscriberIdOrEmailSet.contains(workUser.Email)
				                            || subscriberIdOrEmailSet.contains(workUser.Alias) || subscriberIdOrEmailSet.contains(workUser.UserName)) ){
							EntitySubscription es = parentIdSubscriberIdJoinedKey2EntitySubscription.get(workId+''+workUser.Id);// needs '' in between to avoid the compilation error Arithmetic expressions must use numeric arguments
			                if(null != es){
			                	toBeRemovedfollowers.add(es); 
			                	alreadyAddedSubscriberIds.add(workUser.Id);//Doesn't matter if workUser.Id already existed Set will ignore duplicate.
			                }
		            	}
	            	}
				    alreadyAddedWorkId2SubscriberIdMap.put(workId, alreadyAddedSubscriberIds);
            	
            }
        }

        //Deleting Entity Subsription for those users who are removed from ADM_Work_Subscriber__c
        ADM_EntitySubscriptionUtils.deleteEntitySubscriptions(toBeRemovedfollowers);
       
	}
}