/*
 * This trigger performs the email notifications for eRelease Requests which were previously
 * sent via a set of Workflows.
 *
 *    @testcaseID ADM_eReleaseRequestTest
 *    @userstory W-1224650 https://gus.salesforce.com/a07B0000000LyH4IAK
 *    @author snahm
 */
 
trigger ADM_eReleaseRequestTrigger on eRelease_Request__c (before insert, after insert, after update) {

	if (Trigger.isBefore && Trigger.isInsert) {
		/*
		 * Reset certain fields on new and cloned records
		 */
		for (eRelease_Request__c err : Trigger.new) {
			err.eRelease_Status__c = ADM_eReleaseRequest.ERR_PENDING;		// All ERRs start in Pending state
			err.Released_In__c = null;										// Clear fields that might have been set if record was cloned
			err.Release_Team_Comments__c = null;
			err.Checkin_Location__c = 'The Release Manager will specify the checkin location for the fix and Scheduled Build to use for the checkin.';
		}
		return;
	}

    /*
     * Lookup the Application objects for the eRelease Requests.  Also, set up Maps for 
     * Application -> Application Approvers and a Map of Approver Users.
     */
    // Get Ids of the Application objects that are associated with our ERRs
    Set<Id> appMapKeys = new Set<ID>();         // Set of all Application Ids related to our ERRs
    for (eRelease_Request__c errNew : Trigger.new) {
        if (errNew.Application__c != null) {
            appMapKeys.add(errNew.Application__c);
        }
    }
    if (Trigger.oldMap != null) {
       for (eRelease_Request__c errOld : Trigger.old) {
            if (errOld.Application__c != null) {
                appMapKeys.add(errOld.Application__c);
            }
        }
    }
    // appMap is a Map of Application Ids to Application records
    //      It is used in the section below and in the email notification section   
    Map<Id, ADM_Application__c> appMap;
    try {
    	appMap = new Map<Id, ADM_Application__c>(
        [select Name, Application_Type__c, Enable_ERR_Notification_Emails__c, Primary_Release_Manager__c, Secondary_Release_Manager__c
        from ADM_Application__c where Id = :appMapKeys]);
    } catch (System.Exception e) {
    	System.debug('ADM_eReleaseRequestTrigger: Unexpected exception looking up Applications:' + e + ' Line:' + e.getLineNumber());
    	return;			// Cannot proceed without the appMap
    }
    // *** errAppMap is a Map of eRelease Request Ids to the Id of the Application on that ERR
    //      It is used by the email notification section
    Map</*eRelease_Request__c*/ Id, /*ADM_Application__c*/ Id> errAppMap = new Map<Id, Id>();
    for (eRelease_Request__c err : Trigger.new) {
        /* DEBUG OFF  System.debug('ADM_eReleaseRequestTrigger New: Building errAppMap:' + err);  /* DEBUG */
        if (err.Application__c != null) {
            errAppMap.put(err.id, err.Application__c);
        }
    }
    /* DEBUG OFF System.debug('ADM_eReleaseRequestTrigger: New: appMapKeys:' + appMapKeys);  /* DEBUG */
    /* DEBUG OFF System.debug('ADM_eReleaseRequestTrigger: New: errAppMap:' + errAppMap);  /* DEBUG */
    /* DEBUG OFF
    if (appMap == null) {
        System.debug('ADM_eReleaseRequestTrigger: appMap is NULL!');    
    } else {
      for (Id a : appMapKeys) {
        System.debug('ADM_eReleaseRequestTrigger: New: appMap: ID=' + a + ' : ADM_Application__c=' + appMap.get(a));
      }
    }
    /* DEBUG */
    
    Set</*User*/Id> apprUserIds= new Set<Id>();     // Set of all Users who are Application Approvers
    Map</*ADM_Application__c*/ Id, List<ADM_Application_Approver__c>> appApproverMap =
        ADM_eReleaseRequestTrigger_Utils.getAppApproverMap(appMap, apprUserIds);
    
    // *** approverUsers is a Map of User Ids (who are the Approvers for the Applications associated with our ERRs) to their User record
    Map<Id, User> approverUsers;
    try {
    	approverUsers = new Map<Id, User>([select Name,Email from User where Id =: apprUserIds]);
    } catch (System.Exception e) {
    	System.debug('ADM_eReleaseRequestTrigger: Unexpected exception looking up Users:' + e + ' Line:' + e.getLineNumber());
    }
    /*
     * This section manages the swarming of related Users on our ERRs' Chatter feed
     */ 
    Map<ID, ADM_Work__c> bugs = new Map<ID, ADM_Work__c>();     // Map of Work Ids to Work records

    if (Trigger.isInsert) {     // Newly inserted ERR

            // subscribersToAdd is a Map of ERR Ids to the Set of Users to be added to their feed subcribers list
            Map</* eRelease_Request__c */ ID, Set</*User*/ ID>> subscribersToAdd = new Map<ID, Set<ID>>();

            ADM_eReleaseRequestTrigger_Utils.addBugUsers(trigger.new, bugs, subscribersToAdd);
            /*
             * Pull in the Users related to the Bug_ID__c on the eRelease_Request__c
             */
            List<ADM_Work__c> bugsWithUsers;		// bugsWithUsers is a List of Work items associated with our ERRs
            try {
            	bugsWithUsers = [select Assignee__c,Product_Owner__c,QA_Engineer__c,Tech_Writer__c from ADM_Work__c where ID in :bugs.keySet()];
            } catch (System.Exception e) {
    			System.debug('ADM_eReleaseRequestTrigger: Unexpected exception looking up Users on related bugs:' + e + ' Line:' + e.getLineNumber() + ' Bug IDs:' + bugs.keyset());
    		}
            for (ADM_Work__c work : bugsWithUsers) {
                bugs.put(work.ID, work);
            }

            // Go through the eRelease Request__c records and add the Bug related users to their subscribers list
            ADM_eReleaseRequestTrigger_Utils.addUsersToSubscribe(trigger.new, bugs, appApproverMap, subscribersToAdd);

            /*
             * Convert the map of ERR record subscriber sets into a list of EntitySubscriptions that can be inserted
             */ 
            List <EntitySubscription> esListToAdd = ADM_eReleaseRequestTrigger_Utils.getSubscriberList(subscribersToAdd);

            /* DEBUG OFF   System.debug('eReleaseRequestTrigger: subscribeUsers at isInsert Users being subscribed:');
            for (EntitySubscription subs : esListToAdd) {
                System.debug('    es: ' + subs.id + ' parent: ' + subs.parentId + ' subscriber: ' + subs.subscriberId);
            }               /* DEBUG */
            try {
                /* DEBUG OFF  System.debug(' -- ADDing users');       /* DEBUG */                 
                insert esListToAdd;        
            } catch (System.Exception e) {
                System.debug('ADM_eReleaseRequestTrigger: Unexpected exception adding subscribers:' + e + ' Line:' + e.getLineNumber());
            }
    } else if (Trigger.isUpdate) {     // Updated ERR
        /*
         * On Update the status of the ERR is checked and used to subscribe or unsubscribe users
         *
         * XXX Future: Compare the new and old users and unsubscribe people who were removed and
         *      subscribe the new people.
         */
        Map</* eRelease_Request__c */ ID, Set</*User*/ ID>> subscribersToAdd = new Map<ID, Set<ID>>();
        List<eRelease_Request__c> errsWithAdds = new List<eRelease_Request__c>();
        Map</* eRelease_Request__c */ ID, Set</*User*/ ID>> subscribersToRemove = new Map<ID, Set<ID>>();
        List<eRelease_Request__c> errsWithRemoves = new List<eRelease_Request__c>();
        
        for (eRelease_Request__c request : trigger.new) {

            eRelease_Request__c errOld = Trigger.oldMap.get(request.ID);
            if (errOld == null) {
                // This is bad; should always have an Old version
                System.debug('ADM_eReleaseRequestTrigger: Id ' + request.Id + ' not found in Trigger.old');
                for (eRelease_Request__c err : Trigger.Old) {
                         System.debug('ADM_eReleaseRequestTrigger OLD: Id: ' + err.Id 
                         + ' Status - "' + err.eRelease_Status__c);
                }
                continue; 
            }
            Boolean isResolved = ADM_eReleaseRequestTrigger_Utils.isResolvedState(request.eRelease_Status__c);
            if (isResolved == null) {
                continue;   // Happens if eRelease_Status__c picklist is out of sync with ADM_eReleaseRequestTrigger_Utils.isResolvedState()
            }
            /* DEBUG OFF  System.debug('ADM_eReleaseRequest_SubscribeUsers: NEW status is ' + request.eRelease_Status__c + 
                '; OLD status is ' + errOld.eRelease_Status__c + ' ');  /* DEBUG */
            // When the new state is Active (isResolved == false) always add back the users, in case they unsubscribed
            if (isResolved == false) {
                /* DEBUG OFF  System.debug(' -- ADDing users');     /* DEBUG */
                errsWithAdds.add(request);
            } else {    // isResolvedState == true
                // Only remove subscribers when the previous state was Active (isResolved == false)
                if (ADM_eReleaseRequestTrigger_Utils.isResolvedState(errOld.eRelease_Status__c) == false) {
                    /* DEBUG OFF  System.debug(' -- REMOVing users'); /* DEBUG */
                    errsWithRemoves.add(request);
                }
            }
        }
        ADM_eReleaseRequestTrigger_Utils.addBugUsers(errsWithAdds, bugs, subscribersToAdd);
        ADM_eReleaseRequestTrigger_Utils.addBugUsers(errsWithRemoves, bugs, subscribersToRemove);

        /*
         * Pull in the Users related to the Bug_ID__c on the eRelease_Request__c
         */
        // Get the bugs/users and build a map keyed on the Work ID
        List<ADM_Work__c> bugsWithUsers;
        try {
        	bugsWithUsers = [select Assignee__c,Product_Owner__c,QA_Engineer__c,Tech_Writer__c from ADM_Work__c where ID in :bugs.keySet()];
        } catch (System.Exception e) {
    			System.debug('ADM_eReleaseRequestTrigger: Unexpected exception looking up Users on related bugs:' + e + ' Line:' + e.getLineNumber() + ' Bug IDs:' + bugs.keyset());
    	}
        for (ADM_Work__c work : bugsWithUsers) {
            bugs.put(work.ID, work);
        }
        // Add the Bug related users to errsWithAdds' subscribers list
        ADM_eReleaseRequestTrigger_Utils.addUsersToSubscribe(errsWithAdds, bugs, appApproverMap, subscribersToAdd);
        
        // Add the Bug related users to errsWithRemoves' subscribers list
        ADM_eReleaseRequestTrigger_Utils.addUsersToSubscribe(errsWithRemoves, bugs, appApproverMap, subscribersToRemove);

        /*
         * Convert the map of ERR record subscriber sets into a list of EntitySubscriptions that can be inserted
         */
        List <EntitySubscription> esListToAdd = ADM_eReleaseRequestTrigger_Utils.getSubscriberList(subscribersToAdd);   

        /*
         * Convert the map of ERR record subscribers to remove sets into a list of EntitySubscriptions that can be deleted
         */
        List <EntitySubscription> esListToRemove = ADM_eReleaseRequestTrigger_Utils.getSubscriberList(subscribersToRemove);

        /* 
         * Look up the EntitySubscription records that match these we want to delete
         *  1: Create a set of parentIDs of the records we need to find
         *  2: Select them
         *  3: Convert to a map of subscriber IDs to maps of parentIDs and EntitySubscription records for that subscriber
         *  4: Create a new list of records we found that match the records we want to remove.
         */
        Set </*parentId*/ID> parentIdSet = new Set<ID>();
        for (EntitySubscription es : esListToRemove) {
            parentIdSet.add(es.parentId);       
        }
        for (EntitySubscription es : esListToAdd) {
            parentIdSet.add(es.parentId);       
        }
		List <EntitySubscription> esRecords;
		try {
        	esRecords = [select parentId,subscriberId from EntitySubscription where parentId in :parentIdSet];
		} catch (System.Exception e) {
            System.debug('ADM_eReleaseRequestTrigger: Unexpected exception looking up subscribers:' + e + ' Line:' + e.getLineNumber());
        }

        Map</*subscriberID*/ ID, Map</*parentID*/ID, EntitySubscription>> subsToParentsMap = new Map<ID, Map<ID, EntitySubscription>>();  
        for (EntitySubscription es : esRecords) {
            Map<ID,EntitySubscription> parentsMap;            
            if (subsToParentsMap.containsKey(es.subscriberId)) {
                parentsMap = subsToParentsMap.get(es.subscriberId);
            } else {
                parentsMap = new Map<ID, EntitySubscription>();
            }
            parentsMap.put(es.parentID, es);
            subsToParentsMap.put(es.subscriberId, parentsMap);
        }
        List <EntitySubscription> esListToDelete = new List <EntitySubscription>();
        for (EntitySubscription es : esListToRemove) {
            Map<ID,EntitySubscription> parentsMap = subsToParentsMap.get(es.subscriberID);
            if (parentsMap != null) {
                EntitySubscription esRecord = parentsMap.get(es.parentId);
                if (esRecord != null) {
                    esListToDelete.add(esRecord);
                } 
            }
        }
        /* DEBUG OFF   System.debug('ADM_eReleaseRequestTrigger: subscribeUsers at isUpdate Users being UNsubscribed: ');   
        for (EntitySubscription subs : esListToDelete) {
            System.debug('EntitySubscription: ' + subs.ID + ' parent: ' + subs.parentId + ' subscriber: ' + subs.subscriberId);
        }        /* DEBUG */
        try {
            delete esListToDelete;        
        } catch (System.Exception e) {
            System.debug('ADM_eReleaseRequestTrigger: Unexpected exception removing subscribers:' + e + ' Line:' + e.getLineNumber());
        }
        List <EntitySubscription> esListToInsert = new List <EntitySubscription>();
        for (EntitySubscription es : esListToAdd) {
            Map<ID,EntitySubscription> parentsMap = subsToParentsMap.get(es.subscriberID);
            if (parentsMap != null) {
                if (parentsMap.containsKey(es.parentId)) {
                    continue;   // Don't add it --  already a subscriber
                } 
            }
            esListToInsert.add(es); 
        }
        /* DEBUG OFF    System.debug('ADM_eReleaseRequestTrigger: subscribeUsers at isUpdate Users being subscribed: ');
        for (EntitySubscription subs : esListToInsert) {
            System.debug('EntitySubscription: ' + subs.ID + ' parent: ' + subs.parentId + ' subscriber: ' + subs.subscriberId);
        }          /* DEBUG OFF */
        try {
            insert esListToInsert;        
        } catch (System.Exception e) {
            System.debug('ADM_eReleaseRequestTrigger: Unexpected exception adding subscribers:' + e + ' Line:' + e.getLineNumber());
        }   
    }
    // End of Chatter swarming section
    // NOTE: Trigger could be Update or Insert
    
    /*
     * This section determines whether email should be sent as a result of this update/insert
     * Email rule: if the new state is not the same as the old state, send email
     */
    Boolean emailReady = false;     // set to true when we have email to send

	if (approverUsers == null) {
		return;			// Cannot send email without the list of approver users
	}
  
    /*
     * Initialize the templates for the eRelease notification emails and get a mapping of ERR state to template.
     */
    static Map<String, Id> stateMap = ADM_eReleaseRequestTrigger_Utils.initializeEmailTemplateIds();
    if (stateMap == null) {
		return;			// Cannot send email without email Templates
	}
    static final Set<String> informContext = new Set<String> {
    	ADM_ApplicationApprover.CONTEXT_INFORM,					// Context values used for non-Approved notifications
    	ADM_ApplicationApprover.CONTEXT_MAY,
    	ADM_ApplicationApprover.CONTEXT_MUST
    };
         
    for (eRelease_Request__c errNew : Trigger.new) {
            /* DEBUG OFF  System.debug('ADM_eReleaseRequestTrigger NEW: Status - "' + errNew.eRelease_Status__c
                 + ' ADM_Application__c = ' + errNew.Application__c);   /* DEBUG */      
            // Get matching Old value
            eRelease_Request__c errOld = null;            
            if (Trigger.oldMap != null) {
                errOld = Trigger.oldMap.get(errNew.Id);
                /* DEBUG OFF  
                System.debug('ADM_eReleaseRequestTrigger OLD: "' + errOld);
                if (errOld != null) {
                 System.debug('ADM_eReleaseRequestTrigger OLD: Status=' + errOld.eRelease_Status__c + ' ADM_Application__c =' + errOld.Application__c);             
                }
                /* DEBUG */
            }

            if (errAppMap.containsKey(errNew.id)) {
                ADM_Application__c thisApp = appMap.get(errAppMap.get(errNew.id)); 
                /* DEBUG OFF     System.debug('ADM_eReleaseRequestTrigger: Email alert processing - errNew.id=' + errNew.id + ' thisApp=' + thisApp); /* DEBUG */
                if (thisApp == null || thisApp.Enable_ERR_Notification_Emails__c == false) {
                    continue;       // Do not send email for this app
                }
                if (errNew.eRelease_Status__c != null) {
                       if (errOld != null && (errOld.eRelease_Status__c != null && errNew.eRelease_Status__c.compareTo(errOld.eRelease_Status__c) == 0)) {                	
                       /* DEBUG OFF  System.debug('ADM_eReleaseRequestTrigger: errOld status matched errNew status. Not sending email.'); /* DEBUG */
                            continue;
                       }
                       // Get emails to send
                       List<ADM_Application_Approver__c> apprList = appApproverMap.get(errNew.Application__c);
                       if (apprList == null) {
                            /* DEBUG OFF  System.debug('ADM_eReleaseRequestTrigger: Application ' + errNew.Application__c + ' has no approvers to notify.'); /* DEBUG */
                            continue;
                       }
                       Set<String> emailsSet;
                       if (ADM_eReleaseRequest.ERR_APPROVED.equals(errNew.eRelease_Status__c)) {	// Include Notify When Approved emails
                       		emailsSet = ADM_ApplicationApprover.approverEmails(apprList, approverUsers, 
                            ADM_ApplicationApprover.TYPE_ERELEASES, null, null);
                       } else {
                       		emailsSet = ADM_ApplicationApprover.approverEmails(apprList, approverUsers, 
                            ADM_ApplicationApprover.TYPE_ERELEASES, null, informContext);
                       }
                       
                       /* DEBUG OFF  System.debug('ADM_eReleaseRequestTrigger: Preparing to email for state ' + errNew.eRelease_Status__c 
                                +'; template = ' + stateMap.get(errNew.eRelease_Status__c) + '; emails=' + emailsSet);    /* DEBUG */

                       if (stateMap.get(errNew.eRelease_Status__c) != null) {
                            COM_EmailUtils.to(UserInfo.getUserId(), /*toEmails*/new List<String>(emailsSet))
                             .templateId(stateMap.get(errNew.eRelease_Status__c))
                             .whatId(errNew.Id)
                             .stashForBulk();
                            emailReady = true;
                       }
                }
            }
    }    
    if (emailReady) {
        try {
            COM_EmailUtils.sendBulkEmail();
        } catch (Exception e) {
            System.debug('ADM_eReleaseRequestTrigger: Failed to send email:' + e.getMessage() + ' from line:' + e.getLineNumber());
        }
    }
    // End email determination section
}